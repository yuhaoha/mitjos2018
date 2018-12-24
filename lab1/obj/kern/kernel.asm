
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
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 98 08 ff ff    	lea    -0xf768(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 bc 0a 00 00       	call   f0100b1f <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7f 2b                	jg     f0100095 <test_backtrace+0x55>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010006a:	83 ec 04             	sub    $0x4,%esp
f010006d:	6a 00                	push   $0x0
f010006f:	6a 00                	push   $0x0
f0100071:	6a 00                	push   $0x0
f0100073:	e8 0b 08 00 00       	call   f0100883 <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 b4 08 ff ff    	lea    -0xf74c(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 94 0a 00 00       	call   f0100b1f <cprintf>
}
f010008b:	83 c4 10             	add    $0x10,%esp
f010008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100091:	5b                   	pop    %ebx
f0100092:	5e                   	pop    %esi
f0100093:	5d                   	pop    %ebp
f0100094:	c3                   	ret    
		test_backtrace(x-1);
f0100095:	83 ec 0c             	sub    $0xc,%esp
f0100098:	8d 46 ff             	lea    -0x1(%esi),%eax
f010009b:	50                   	push   %eax
f010009c:	e8 9f ff ff ff       	call   f0100040 <test_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d5                	jmp    f010007b <test_backtrace+0x3b>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 92 16 00 00       	call   f0101761 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3d 05 00 00       	call   f0100611 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 cf 08 ff ff    	lea    -0xf731(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 37 0a 00 00       	call   f0100b1f <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 62 08 00 00       	call   f0100963 <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	57                   	push   %edi
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	83 ec 0c             	sub    $0xc,%esp
f010010f:	e8 a8 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100114:	81 c3 f4 11 01 00    	add    $0x111f4,%ebx
f010011a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010011d:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f0100123:	83 38 00             	cmpl   $0x0,(%eax)
f0100126:	74 0f                	je     f0100137 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100128:	83 ec 0c             	sub    $0xc,%esp
f010012b:	6a 00                	push   $0x0
f010012d:	e8 31 08 00 00       	call   f0100963 <monitor>
f0100132:	83 c4 10             	add    $0x10,%esp
f0100135:	eb f1                	jmp    f0100128 <_panic+0x22>
	panicstr = fmt;
f0100137:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    
	va_start(ap, fmt);
f010013b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	8d 83 ea 08 ff ff    	lea    -0xf716(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 cc 09 00 00       	call   f0100b1f <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 8b 09 00 00       	call   f0100ae8 <vcprintf>
	cprintf("\n");
f010015d:	8d 83 26 09 ff ff    	lea    -0xf6da(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 b4 09 00 00       	call   f0100b1f <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb b8                	jmp    f0100128 <_panic+0x22>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 02 09 ff ff    	lea    -0xf6fe(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 87 09 00 00       	call   f0100b1f <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 44 09 00 00       	call   f0100ae8 <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 26 09 ff ff    	lea    -0xf6da(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 6d 09 00 00       	call   f0100b1f <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c9:	a8 01                	test   $0x1,%al
f01001cb:	74 0b                	je     f01001d8 <serial_proc_data+0x18>
f01001cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d3:	0f b6 c0             	movzbl %al,%eax
}
f01001d6:	5d                   	pop    %ebp
f01001d7:	c3                   	ret    
		return -1;
f01001d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001dd:	eb f7                	jmp    f01001d6 <serial_proc_data+0x16>

f01001df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	e8 d3 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01001e9:	81 c3 1f 11 01 00    	add    $0x1111f,%ebx
f01001ef:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d6                	call   *%esi
f01001f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f6:	74 2e                	je     f0100226 <cons_intr+0x47>
		if (c == 0)
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	74 f5                	je     f01001f1 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fc:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010020b:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100212:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100218:	75 d7                	jne    f01001f1 <cons_intr+0x12>
			cons.wpos = 0;
f010021a:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f0100221:	00 00 00 
f0100224:	eb cb                	jmp    f01001f1 <cons_intr+0x12>
	}
}
f0100226:	5b                   	pop    %ebx
f0100227:	5e                   	pop    %esi
f0100228:	5d                   	pop    %ebp
f0100229:	c3                   	ret    

f010022a <kbd_proc_data>:
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	56                   	push   %esi
f010022e:	53                   	push   %ebx
f010022f:	e8 88 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100234:	81 c3 d4 10 01 00    	add    $0x110d4,%ebx
f010023a:	ba 64 00 00 00       	mov    $0x64,%edx
f010023f:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100240:	a8 01                	test   $0x1,%al
f0100242:	0f 84 06 01 00 00    	je     f010034e <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100248:	a8 20                	test   $0x20,%al
f010024a:	0f 85 05 01 00 00    	jne    f0100355 <kbd_proc_data+0x12b>
f0100250:	ba 60 00 00 00       	mov    $0x60,%edx
f0100255:	ec                   	in     (%dx),%al
f0100256:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100258:	3c e0                	cmp    $0xe0,%al
f010025a:	0f 84 93 00 00 00    	je     f01002f3 <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f0100260:	84 c0                	test   %al,%al
f0100262:	0f 88 a0 00 00 00    	js     f0100308 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100268:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010026e:	f6 c1 40             	test   $0x40,%cl
f0100271:	74 0e                	je     f0100281 <kbd_proc_data+0x57>
		data |= 0x80;
f0100273:	83 c8 80             	or     $0xffffff80,%eax
f0100276:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100278:	83 e1 bf             	and    $0xffffffbf,%ecx
f010027b:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100281:	0f b6 d2             	movzbl %dl,%edx
f0100284:	0f b6 84 13 58 0a ff 	movzbl -0xf5a8(%ebx,%edx,1),%eax
f010028b:	ff 
f010028c:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100292:	0f b6 8c 13 58 09 ff 	movzbl -0xf6a8(%ebx,%edx,1),%ecx
f0100299:	ff 
f010029a:	31 c8                	xor    %ecx,%eax
f010029c:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a2:	89 c1                	mov    %eax,%ecx
f01002a4:	83 e1 03             	and    $0x3,%ecx
f01002a7:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ae:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002b2:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002b5:	a8 08                	test   $0x8,%al
f01002b7:	74 0d                	je     f01002c6 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002b9:	89 f2                	mov    %esi,%edx
f01002bb:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002be:	83 f9 19             	cmp    $0x19,%ecx
f01002c1:	77 7a                	ja     f010033d <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002c3:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c6:	f7 d0                	not    %eax
f01002c8:	a8 06                	test   $0x6,%al
f01002ca:	75 33                	jne    f01002ff <kbd_proc_data+0xd5>
f01002cc:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002d2:	75 2b                	jne    f01002ff <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01002d4:	83 ec 0c             	sub    $0xc,%esp
f01002d7:	8d 83 1c 09 ff ff    	lea    -0xf6e4(%ebx),%eax
f01002dd:	50                   	push   %eax
f01002de:	e8 3c 08 00 00       	call   f0100b1f <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e8:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ed:	ee                   	out    %al,(%dx)
f01002ee:	83 c4 10             	add    $0x10,%esp
f01002f1:	eb 0c                	jmp    f01002ff <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002f3:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002fa:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002ff:	89 f0                	mov    %esi,%eax
f0100301:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100304:	5b                   	pop    %ebx
f0100305:	5e                   	pop    %esi
f0100306:	5d                   	pop    %ebp
f0100307:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100308:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010030e:	89 ce                	mov    %ecx,%esi
f0100310:	83 e6 40             	and    $0x40,%esi
f0100313:	83 e0 7f             	and    $0x7f,%eax
f0100316:	85 f6                	test   %esi,%esi
f0100318:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031b:	0f b6 d2             	movzbl %dl,%edx
f010031e:	0f b6 84 13 58 0a ff 	movzbl -0xf5a8(%ebx,%edx,1),%eax
f0100325:	ff 
f0100326:	83 c8 40             	or     $0x40,%eax
f0100329:	0f b6 c0             	movzbl %al,%eax
f010032c:	f7 d0                	not    %eax
f010032e:	21 c8                	and    %ecx,%eax
f0100330:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f0100336:	be 00 00 00 00       	mov    $0x0,%esi
f010033b:	eb c2                	jmp    f01002ff <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f010033d:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100340:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100343:	83 fa 1a             	cmp    $0x1a,%edx
f0100346:	0f 42 f1             	cmovb  %ecx,%esi
f0100349:	e9 78 ff ff ff       	jmp    f01002c6 <kbd_proc_data+0x9c>
		return -1;
f010034e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100353:	eb aa                	jmp    f01002ff <kbd_proc_data+0xd5>
		return -1;
f0100355:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035a:	eb a3                	jmp    f01002ff <kbd_proc_data+0xd5>

f010035c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010035c:	55                   	push   %ebp
f010035d:	89 e5                	mov    %esp,%ebp
f010035f:	57                   	push   %edi
f0100360:	56                   	push   %esi
f0100361:	53                   	push   %ebx
f0100362:	83 ec 1c             	sub    $0x1c,%esp
f0100365:	e8 52 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010036a:	81 c3 9e 0f 01 00    	add    $0x10f9e,%ebx
f0100370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100373:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100378:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010037d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100382:	eb 09                	jmp    f010038d <cons_putc+0x31>
f0100384:	89 ca                	mov    %ecx,%edx
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
f0100389:	ec                   	in     (%dx),%al
	     i++)
f010038a:	83 c6 01             	add    $0x1,%esi
f010038d:	89 fa                	mov    %edi,%edx
f010038f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100390:	a8 20                	test   $0x20,%al
f0100392:	75 08                	jne    f010039c <cons_putc+0x40>
f0100394:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010039a:	7e e8                	jle    f0100384 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039f:	89 f8                	mov    %edi,%eax
f01003a1:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a9:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003aa:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003af:	bf 79 03 00 00       	mov    $0x379,%edi
f01003b4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b9:	eb 09                	jmp    f01003c4 <cons_putc+0x68>
f01003bb:	89 ca                	mov    %ecx,%edx
f01003bd:	ec                   	in     (%dx),%al
f01003be:	ec                   	in     (%dx),%al
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	83 c6 01             	add    $0x1,%esi
f01003c4:	89 fa                	mov    %edi,%edx
f01003c6:	ec                   	in     (%dx),%al
f01003c7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003cd:	7f 04                	jg     f01003d3 <cons_putc+0x77>
f01003cf:	84 c0                	test   %al,%al
f01003d1:	79 e8                	jns    f01003bb <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d3:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d8:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003dc:	ee                   	out    %al,(%dx)
f01003dd:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e7:	ee                   	out    %al,(%dx)
f01003e8:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ed:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f1:	89 fa                	mov    %edi,%edx
f01003f3:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003f9:	89 f8                	mov    %edi,%eax
f01003fb:	80 cc 07             	or     $0x7,%ah
f01003fe:	85 d2                	test   %edx,%edx
f0100400:	0f 45 c7             	cmovne %edi,%eax
f0100403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100406:	0f b6 c0             	movzbl %al,%eax
f0100409:	83 f8 09             	cmp    $0x9,%eax
f010040c:	0f 84 b9 00 00 00    	je     f01004cb <cons_putc+0x16f>
f0100412:	83 f8 09             	cmp    $0x9,%eax
f0100415:	7e 74                	jle    f010048b <cons_putc+0x12f>
f0100417:	83 f8 0a             	cmp    $0xa,%eax
f010041a:	0f 84 9e 00 00 00    	je     f01004be <cons_putc+0x162>
f0100420:	83 f8 0d             	cmp    $0xd,%eax
f0100423:	0f 85 d9 00 00 00    	jne    f0100502 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100429:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100430:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100436:	c1 e8 16             	shr    $0x16,%eax
f0100439:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043c:	c1 e0 04             	shl    $0x4,%eax
f010043f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100446:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010044d:	cf 07 
f010044f:	0f 87 d4 00 00 00    	ja     f0100529 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100455:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f010045b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100460:	89 ca                	mov    %ecx,%edx
f0100462:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100463:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f010046a:	8d 71 01             	lea    0x1(%ecx),%esi
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	66 c1 e8 08          	shr    $0x8,%ax
f0100473:	89 f2                	mov    %esi,%edx
f0100475:	ee                   	out    %al,(%dx)
f0100476:	b8 0f 00 00 00       	mov    $0xf,%eax
f010047b:	89 ca                	mov    %ecx,%edx
f010047d:	ee                   	out    %al,(%dx)
f010047e:	89 d8                	mov    %ebx,%eax
f0100480:	89 f2                	mov    %esi,%edx
f0100482:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100483:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100486:	5b                   	pop    %ebx
f0100487:	5e                   	pop    %esi
f0100488:	5f                   	pop    %edi
f0100489:	5d                   	pop    %ebp
f010048a:	c3                   	ret    
	switch (c & 0xff) {
f010048b:	83 f8 08             	cmp    $0x8,%eax
f010048e:	75 72                	jne    f0100502 <cons_putc+0x1a6>
		if (crt_pos > 0) {
f0100490:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100497:	66 85 c0             	test   %ax,%ax
f010049a:	74 b9                	je     f0100455 <cons_putc+0xf9>
			crt_pos--;
f010049c:	83 e8 01             	sub    $0x1,%eax
f010049f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ad:	b2 00                	mov    $0x0,%dl
f01004af:	83 ca 20             	or     $0x20,%edx
f01004b2:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004b8:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004bc:	eb 88                	jmp    f0100446 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01004be:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004c5:	50 
f01004c6:	e9 5e ff ff ff       	jmp    f0100429 <cons_putc+0xcd>
		cons_putc(' ');
f01004cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d0:	e8 87 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004da:	e8 7d fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004df:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e4:	e8 73 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ee:	e8 69 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f8:	e8 5f fe ff ff       	call   f010035c <cons_putc>
f01004fd:	e9 44 ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100502:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100509:	8d 50 01             	lea    0x1(%eax),%edx
f010050c:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100513:	0f b7 c0             	movzwl %ax,%eax
f0100516:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010051c:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100520:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100524:	e9 1d ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100529:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010052f:	83 ec 04             	sub    $0x4,%esp
f0100532:	68 00 0f 00 00       	push   $0xf00
f0100537:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010053d:	52                   	push   %edx
f010053e:	50                   	push   %eax
f010053f:	e8 6a 12 00 00       	call   f01017ae <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100544:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010054a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100550:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100556:	83 c4 10             	add    $0x10,%esp
f0100559:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010055e:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100561:	39 d0                	cmp    %edx,%eax
f0100563:	75 f4                	jne    f0100559 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100565:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010056c:	50 
f010056d:	e9 e3 fe ff ff       	jmp    f0100455 <cons_putc+0xf9>

f0100572 <serial_intr>:
{
f0100572:	e8 e7 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f0100577:	05 91 0d 01 00       	add    $0x10d91,%eax
	if (serial_exists)
f010057c:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100583:	75 02                	jne    f0100587 <serial_intr+0x15>
f0100585:	f3 c3                	repz ret 
{
f0100587:	55                   	push   %ebp
f0100588:	89 e5                	mov    %esp,%ebp
f010058a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010058d:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f0100593:	e8 47 fc ff ff       	call   f01001df <cons_intr>
}
f0100598:	c9                   	leave  
f0100599:	c3                   	ret    

f010059a <kbd_intr>:
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	83 ec 08             	sub    $0x8,%esp
f01005a0:	e8 b9 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f01005a5:	05 63 0d 01 00       	add    $0x10d63,%eax
	cons_intr(kbd_proc_data);
f01005aa:	8d 80 22 ef fe ff    	lea    -0x110de(%eax),%eax
f01005b0:	e8 2a fc ff ff       	call   f01001df <cons_intr>
}
f01005b5:	c9                   	leave  
f01005b6:	c3                   	ret    

f01005b7 <cons_getc>:
{
f01005b7:	55                   	push   %ebp
f01005b8:	89 e5                	mov    %esp,%ebp
f01005ba:	53                   	push   %ebx
f01005bb:	83 ec 04             	sub    $0x4,%esp
f01005be:	e8 f9 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005c3:	81 c3 45 0d 01 00    	add    $0x10d45,%ebx
	serial_intr();
f01005c9:	e8 a4 ff ff ff       	call   f0100572 <serial_intr>
	kbd_intr();
f01005ce:	e8 c7 ff ff ff       	call   f010059a <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005d3:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f01005d9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005de:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f01005e4:	74 19                	je     f01005ff <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005e9:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f01005ef:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f01005f6:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005f7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005fd:	74 06                	je     f0100605 <cons_getc+0x4e>
}
f01005ff:	83 c4 04             	add    $0x4,%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5d                   	pop    %ebp
f0100604:	c3                   	ret    
			cons.rpos = 0;
f0100605:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010060c:	00 00 00 
f010060f:	eb ee                	jmp    f01005ff <cons_getc+0x48>

f0100611 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	57                   	push   %edi
f0100615:	56                   	push   %esi
f0100616:	53                   	push   %ebx
f0100617:	83 ec 1c             	sub    $0x1c,%esp
f010061a:	e8 9d fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010061f:	81 c3 e9 0c 01 00    	add    $0x10ce9,%ebx
	was = *cp;
f0100625:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100633:	5a a5 
	if (*cp != 0xA55A) {
f0100635:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100640:	0f 84 bc 00 00 00    	je     f0100702 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100646:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010064d:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100650:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100657:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010065d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100662:	89 fa                	mov    %edi,%edx
f0100664:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100665:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100668:	89 ca                	mov    %ecx,%edx
f010066a:	ec                   	in     (%dx),%al
f010066b:	0f b6 f0             	movzbl %al,%esi
f010066e:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100671:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100676:	89 fa                	mov    %edi,%edx
f0100678:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100679:	89 ca                	mov    %ecx,%edx
f010067b:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010067f:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100685:	0f b6 c0             	movzbl %al,%eax
f0100688:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010068a:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100691:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100696:	89 c8                	mov    %ecx,%eax
f0100698:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010069d:	ee                   	out    %al,(%dx)
f010069e:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006a3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a8:	89 fa                	mov    %edi,%edx
f01006aa:	ee                   	out    %al,(%dx)
f01006ab:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006b0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b5:	ee                   	out    %al,(%dx)
f01006b6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006bb:	89 c8                	mov    %ecx,%eax
f01006bd:	89 f2                	mov    %esi,%edx
f01006bf:	ee                   	out    %al,(%dx)
f01006c0:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c5:	89 fa                	mov    %edi,%edx
f01006c7:	ee                   	out    %al,(%dx)
f01006c8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006cd:	89 c8                	mov    %ecx,%eax
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d5:	89 f2                	mov    %esi,%edx
f01006d7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006dd:	ec                   	in     (%dx),%al
f01006de:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006e0:	3c ff                	cmp    $0xff,%al
f01006e2:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006e9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006ee:	ec                   	in     (%dx),%al
f01006ef:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f4:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f5:	80 f9 ff             	cmp    $0xff,%cl
f01006f8:	74 25                	je     f010071f <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006fd:	5b                   	pop    %ebx
f01006fe:	5e                   	pop    %esi
f01006ff:	5f                   	pop    %edi
f0100700:	5d                   	pop    %ebp
f0100701:	c3                   	ret    
		*cp = was;
f0100702:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100709:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100710:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100713:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010071a:	e9 38 ff ff ff       	jmp    f0100657 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f010071f:	83 ec 0c             	sub    $0xc,%esp
f0100722:	8d 83 28 09 ff ff    	lea    -0xf6d8(%ebx),%eax
f0100728:	50                   	push   %eax
f0100729:	e8 f1 03 00 00       	call   f0100b1f <cprintf>
f010072e:	83 c4 10             	add    $0x10,%esp
}
f0100731:	eb c7                	jmp    f01006fa <cons_init+0xe9>

f0100733 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100739:	8b 45 08             	mov    0x8(%ebp),%eax
f010073c:	e8 1b fc ff ff       	call   f010035c <cons_putc>
}
f0100741:	c9                   	leave  
f0100742:	c3                   	ret    

f0100743 <getchar>:

int
getchar(void)
{
f0100743:	55                   	push   %ebp
f0100744:	89 e5                	mov    %esp,%ebp
f0100746:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100749:	e8 69 fe ff ff       	call   f01005b7 <cons_getc>
f010074e:	85 c0                	test   %eax,%eax
f0100750:	74 f7                	je     f0100749 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100752:	c9                   	leave  
f0100753:	c3                   	ret    

f0100754 <iscons>:

int
iscons(int fdnum)
{
f0100754:	55                   	push   %ebp
f0100755:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100757:	b8 01 00 00 00       	mov    $0x1,%eax
f010075c:	5d                   	pop    %ebp
f010075d:	c3                   	ret    

f010075e <__x86.get_pc_thunk.ax>:
f010075e:	8b 04 24             	mov    (%esp),%eax
f0100761:	c3                   	ret    

f0100762 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100762:	55                   	push   %ebp
f0100763:	89 e5                	mov    %esp,%ebp
f0100765:	56                   	push   %esi
f0100766:	53                   	push   %ebx
f0100767:	e8 50 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010076c:	81 c3 9c 0b 01 00    	add    $0x10b9c,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100772:	83 ec 04             	sub    $0x4,%esp
f0100775:	8d 83 58 0b ff ff    	lea    -0xf4a8(%ebx),%eax
f010077b:	50                   	push   %eax
f010077c:	8d 83 76 0b ff ff    	lea    -0xf48a(%ebx),%eax
f0100782:	50                   	push   %eax
f0100783:	8d b3 7b 0b ff ff    	lea    -0xf485(%ebx),%esi
f0100789:	56                   	push   %esi
f010078a:	e8 90 03 00 00       	call   f0100b1f <cprintf>
f010078f:	83 c4 0c             	add    $0xc,%esp
f0100792:	8d 83 24 0c ff ff    	lea    -0xf3dc(%ebx),%eax
f0100798:	50                   	push   %eax
f0100799:	8d 83 84 0b ff ff    	lea    -0xf47c(%ebx),%eax
f010079f:	50                   	push   %eax
f01007a0:	56                   	push   %esi
f01007a1:	e8 79 03 00 00       	call   f0100b1f <cprintf>
	return 0;
}
f01007a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007ae:	5b                   	pop    %ebx
f01007af:	5e                   	pop    %esi
f01007b0:	5d                   	pop    %ebp
f01007b1:	c3                   	ret    

f01007b2 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b2:	55                   	push   %ebp
f01007b3:	89 e5                	mov    %esp,%ebp
f01007b5:	57                   	push   %edi
f01007b6:	56                   	push   %esi
f01007b7:	53                   	push   %ebx
f01007b8:	83 ec 18             	sub    $0x18,%esp
f01007bb:	e8 fc f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007c0:	81 c3 48 0b 01 00    	add    $0x10b48,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c6:	8d 83 8d 0b ff ff    	lea    -0xf473(%ebx),%eax
f01007cc:	50                   	push   %eax
f01007cd:	e8 4d 03 00 00       	call   f0100b1f <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d2:	83 c4 08             	add    $0x8,%esp
f01007d5:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007db:	8d 83 4c 0c ff ff    	lea    -0xf3b4(%ebx),%eax
f01007e1:	50                   	push   %eax
f01007e2:	e8 38 03 00 00       	call   f0100b1f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e7:	83 c4 0c             	add    $0xc,%esp
f01007ea:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007f0:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007f6:	50                   	push   %eax
f01007f7:	57                   	push   %edi
f01007f8:	8d 83 74 0c ff ff    	lea    -0xf38c(%ebx),%eax
f01007fe:	50                   	push   %eax
f01007ff:	e8 1b 03 00 00       	call   f0100b1f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100804:	83 c4 0c             	add    $0xc,%esp
f0100807:	c7 c0 99 1b 10 f0    	mov    $0xf0101b99,%eax
f010080d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100813:	52                   	push   %edx
f0100814:	50                   	push   %eax
f0100815:	8d 83 98 0c ff ff    	lea    -0xf368(%ebx),%eax
f010081b:	50                   	push   %eax
f010081c:	e8 fe 02 00 00       	call   f0100b1f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100821:	83 c4 0c             	add    $0xc,%esp
f0100824:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f010082a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100830:	52                   	push   %edx
f0100831:	50                   	push   %eax
f0100832:	8d 83 bc 0c ff ff    	lea    -0xf344(%ebx),%eax
f0100838:	50                   	push   %eax
f0100839:	e8 e1 02 00 00       	call   f0100b1f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010083e:	83 c4 0c             	add    $0xc,%esp
f0100841:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f0100847:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010084d:	50                   	push   %eax
f010084e:	56                   	push   %esi
f010084f:	8d 83 e0 0c ff ff    	lea    -0xf320(%ebx),%eax
f0100855:	50                   	push   %eax
f0100856:	e8 c4 02 00 00       	call   f0100b1f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085b:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010085e:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f0100864:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	c1 fe 0a             	sar    $0xa,%esi
f0100869:	56                   	push   %esi
f010086a:	8d 83 04 0d ff ff    	lea    -0xf2fc(%ebx),%eax
f0100870:	50                   	push   %eax
f0100871:	e8 a9 02 00 00       	call   f0100b1f <cprintf>
	return 0;
}
f0100876:	b8 00 00 00 00       	mov    $0x0,%eax
f010087b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010087e:	5b                   	pop    %ebx
f010087f:	5e                   	pop    %esi
f0100880:	5f                   	pop    %edi
f0100881:	5d                   	pop    %ebp
f0100882:	c3                   	ret    

f0100883 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100883:	55                   	push   %ebp
f0100884:	89 e5                	mov    %esp,%ebp
f0100886:	57                   	push   %edi
f0100887:	56                   	push   %esi
f0100888:	53                   	push   %ebx
f0100889:	83 ec 48             	sub    $0x48,%esp
f010088c:	e8 2b f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100891:	81 c3 77 0a 01 00    	add    $0x10a77,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100897:	89 e8                	mov    %ebp,%eax
	// Your code here.
	unsigned int *ebp = ((unsigned int*)read_ebp());
f0100899:	89 c7                	mov    %eax,%edi
	cprintf("Stack backtrace:\n");
f010089b:	8d 83 a6 0b ff ff    	lea    -0xf45a(%ebx),%eax
f01008a1:	50                   	push   %eax
f01008a2:	e8 78 02 00 00       	call   f0100b1f <cprintf>

	while(ebp) {
f01008a7:	83 c4 10             	add    $0x10,%esp
		cprintf("ebp %08x ", ebp);
f01008aa:	8d 83 b8 0b ff ff    	lea    -0xf448(%ebx),%eax
f01008b0:	89 45 bc             	mov    %eax,-0x44(%ebp)
		cprintf("eip %08x args", ebp[1]);
f01008b3:	8d 83 c2 0b ff ff    	lea    -0xf43e(%ebx),%eax
f01008b9:	89 45 b8             	mov    %eax,-0x48(%ebp)
	while(ebp) {
f01008bc:	e9 8d 00 00 00       	jmp    f010094e <mon_backtrace+0xcb>
		cprintf("ebp %08x ", ebp);
f01008c1:	83 ec 08             	sub    $0x8,%esp
f01008c4:	57                   	push   %edi
f01008c5:	ff 75 bc             	pushl  -0x44(%ebp)
f01008c8:	e8 52 02 00 00       	call   f0100b1f <cprintf>
		cprintf("eip %08x args", ebp[1]);
f01008cd:	83 c4 08             	add    $0x8,%esp
f01008d0:	ff 77 04             	pushl  0x4(%edi)
f01008d3:	ff 75 b8             	pushl  -0x48(%ebp)
f01008d6:	e8 44 02 00 00       	call   f0100b1f <cprintf>
f01008db:	8d 77 08             	lea    0x8(%edi),%esi
f01008de:	8d 47 1c             	lea    0x1c(%edi),%eax
f01008e1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01008e4:	83 c4 10             	add    $0x10,%esp
		for(int i = 2; i <= 6; i++)
			cprintf(" %08x", ebp[i]);
f01008e7:	8d 83 d0 0b ff ff    	lea    -0xf430(%ebx),%eax
f01008ed:	89 7d c0             	mov    %edi,-0x40(%ebp)
f01008f0:	89 c7                	mov    %eax,%edi
f01008f2:	83 ec 08             	sub    $0x8,%esp
f01008f5:	ff 36                	pushl  (%esi)
f01008f7:	57                   	push   %edi
f01008f8:	e8 22 02 00 00       	call   f0100b1f <cprintf>
f01008fd:	83 c6 04             	add    $0x4,%esi
		for(int i = 2; i <= 6; i++)
f0100900:	83 c4 10             	add    $0x10,%esp
f0100903:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f0100906:	75 ea                	jne    f01008f2 <mon_backtrace+0x6f>
f0100908:	8b 7d c0             	mov    -0x40(%ebp),%edi
		cprintf("\n");
f010090b:	83 ec 0c             	sub    $0xc,%esp
f010090e:	8d 83 26 09 ff ff    	lea    -0xf6da(%ebx),%eax
f0100914:	50                   	push   %eax
f0100915:	e8 05 02 00 00       	call   f0100b1f <cprintf>

		unsigned int eip = ebp[1];
f010091a:	8b 77 04             	mov    0x4(%edi),%esi
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f010091d:	83 c4 08             	add    $0x8,%esp
f0100920:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100923:	50                   	push   %eax
f0100924:	56                   	push   %esi
f0100925:	e8 f9 02 00 00       	call   f0100c23 <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n",
f010092a:	83 c4 08             	add    $0x8,%esp
f010092d:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100930:	56                   	push   %esi
f0100931:	ff 75 d8             	pushl  -0x28(%ebp)
f0100934:	ff 75 dc             	pushl  -0x24(%ebp)
f0100937:	ff 75 d4             	pushl  -0x2c(%ebp)
f010093a:	ff 75 d0             	pushl  -0x30(%ebp)
f010093d:	8d 83 d6 0b ff ff    	lea    -0xf42a(%ebx),%eax
f0100943:	50                   	push   %eax
f0100944:	e8 d6 01 00 00       	call   f0100b1f <cprintf>
		info.eip_file, info.eip_line,
		info.eip_fn_namelen, info.eip_fn_name,
		eip-info.eip_fn_addr);

		ebp = (unsigned int*)(*ebp);
f0100949:	8b 3f                	mov    (%edi),%edi
f010094b:	83 c4 20             	add    $0x20,%esp
	while(ebp) {
f010094e:	85 ff                	test   %edi,%edi
f0100950:	0f 85 6b ff ff ff    	jne    f01008c1 <mon_backtrace+0x3e>
	}
	return 0;
}
f0100956:	b8 00 00 00 00       	mov    $0x0,%eax
f010095b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010095e:	5b                   	pop    %ebx
f010095f:	5e                   	pop    %esi
f0100960:	5f                   	pop    %edi
f0100961:	5d                   	pop    %ebp
f0100962:	c3                   	ret    

f0100963 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100963:	55                   	push   %ebp
f0100964:	89 e5                	mov    %esp,%ebp
f0100966:	57                   	push   %edi
f0100967:	56                   	push   %esi
f0100968:	53                   	push   %ebx
f0100969:	83 ec 68             	sub    $0x68,%esp
f010096c:	e8 4b f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100971:	81 c3 97 09 01 00    	add    $0x10997,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100977:	8d 83 30 0d ff ff    	lea    -0xf2d0(%ebx),%eax
f010097d:	50                   	push   %eax
f010097e:	e8 9c 01 00 00       	call   f0100b1f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100983:	8d 83 54 0d ff ff    	lea    -0xf2ac(%ebx),%eax
f0100989:	89 04 24             	mov    %eax,(%esp)
f010098c:	e8 8e 01 00 00       	call   f0100b1f <cprintf>
f0100991:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100994:	8d bb eb 0b ff ff    	lea    -0xf415(%ebx),%edi
f010099a:	eb 4a                	jmp    f01009e6 <monitor+0x83>
f010099c:	83 ec 08             	sub    $0x8,%esp
f010099f:	0f be c0             	movsbl %al,%eax
f01009a2:	50                   	push   %eax
f01009a3:	57                   	push   %edi
f01009a4:	e8 7b 0d 00 00       	call   f0101724 <strchr>
f01009a9:	83 c4 10             	add    $0x10,%esp
f01009ac:	85 c0                	test   %eax,%eax
f01009ae:	74 08                	je     f01009b8 <monitor+0x55>
			*buf++ = 0;
f01009b0:	c6 06 00             	movb   $0x0,(%esi)
f01009b3:	8d 76 01             	lea    0x1(%esi),%esi
f01009b6:	eb 79                	jmp    f0100a31 <monitor+0xce>
		if (*buf == 0)
f01009b8:	80 3e 00             	cmpb   $0x0,(%esi)
f01009bb:	74 7f                	je     f0100a3c <monitor+0xd9>
		if (argc == MAXARGS-1) {
f01009bd:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009c1:	74 0f                	je     f01009d2 <monitor+0x6f>
		argv[argc++] = buf;
f01009c3:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009c6:	8d 48 01             	lea    0x1(%eax),%ecx
f01009c9:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009cc:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f01009d0:	eb 44                	jmp    f0100a16 <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009d2:	83 ec 08             	sub    $0x8,%esp
f01009d5:	6a 10                	push   $0x10
f01009d7:	8d 83 f0 0b ff ff    	lea    -0xf410(%ebx),%eax
f01009dd:	50                   	push   %eax
f01009de:	e8 3c 01 00 00       	call   f0100b1f <cprintf>
f01009e3:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009e6:	8d 83 e7 0b ff ff    	lea    -0xf419(%ebx),%eax
f01009ec:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01009ef:	83 ec 0c             	sub    $0xc,%esp
f01009f2:	ff 75 a4             	pushl  -0x5c(%ebp)
f01009f5:	e8 f2 0a 00 00       	call   f01014ec <readline>
f01009fa:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009fc:	83 c4 10             	add    $0x10,%esp
f01009ff:	85 c0                	test   %eax,%eax
f0100a01:	74 ec                	je     f01009ef <monitor+0x8c>
	argv[argc] = 0;
f0100a03:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a0a:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100a11:	eb 1e                	jmp    f0100a31 <monitor+0xce>
			buf++;
f0100a13:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a16:	0f b6 06             	movzbl (%esi),%eax
f0100a19:	84 c0                	test   %al,%al
f0100a1b:	74 14                	je     f0100a31 <monitor+0xce>
f0100a1d:	83 ec 08             	sub    $0x8,%esp
f0100a20:	0f be c0             	movsbl %al,%eax
f0100a23:	50                   	push   %eax
f0100a24:	57                   	push   %edi
f0100a25:	e8 fa 0c 00 00       	call   f0101724 <strchr>
f0100a2a:	83 c4 10             	add    $0x10,%esp
f0100a2d:	85 c0                	test   %eax,%eax
f0100a2f:	74 e2                	je     f0100a13 <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a31:	0f b6 06             	movzbl (%esi),%eax
f0100a34:	84 c0                	test   %al,%al
f0100a36:	0f 85 60 ff ff ff    	jne    f010099c <monitor+0x39>
	argv[argc] = 0;
f0100a3c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a3f:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a46:	00 
	if (argc == 0)
f0100a47:	85 c0                	test   %eax,%eax
f0100a49:	74 9b                	je     f01009e6 <monitor+0x83>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a4b:	83 ec 08             	sub    $0x8,%esp
f0100a4e:	8d 83 76 0b ff ff    	lea    -0xf48a(%ebx),%eax
f0100a54:	50                   	push   %eax
f0100a55:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a58:	e8 69 0c 00 00       	call   f01016c6 <strcmp>
f0100a5d:	83 c4 10             	add    $0x10,%esp
f0100a60:	85 c0                	test   %eax,%eax
f0100a62:	74 38                	je     f0100a9c <monitor+0x139>
f0100a64:	83 ec 08             	sub    $0x8,%esp
f0100a67:	8d 83 84 0b ff ff    	lea    -0xf47c(%ebx),%eax
f0100a6d:	50                   	push   %eax
f0100a6e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a71:	e8 50 0c 00 00       	call   f01016c6 <strcmp>
f0100a76:	83 c4 10             	add    $0x10,%esp
f0100a79:	85 c0                	test   %eax,%eax
f0100a7b:	74 1a                	je     f0100a97 <monitor+0x134>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a7d:	83 ec 08             	sub    $0x8,%esp
f0100a80:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a83:	8d 83 0d 0c ff ff    	lea    -0xf3f3(%ebx),%eax
f0100a89:	50                   	push   %eax
f0100a8a:	e8 90 00 00 00       	call   f0100b1f <cprintf>
f0100a8f:	83 c4 10             	add    $0x10,%esp
f0100a92:	e9 4f ff ff ff       	jmp    f01009e6 <monitor+0x83>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a97:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a9c:	83 ec 04             	sub    $0x4,%esp
f0100a9f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100aa2:	ff 75 08             	pushl  0x8(%ebp)
f0100aa5:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100aa8:	52                   	push   %edx
f0100aa9:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100aac:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100ab3:	83 c4 10             	add    $0x10,%esp
f0100ab6:	85 c0                	test   %eax,%eax
f0100ab8:	0f 89 28 ff ff ff    	jns    f01009e6 <monitor+0x83>
				break;
	}
}
f0100abe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ac1:	5b                   	pop    %ebx
f0100ac2:	5e                   	pop    %esi
f0100ac3:	5f                   	pop    %edi
f0100ac4:	5d                   	pop    %ebp
f0100ac5:	c3                   	ret    

f0100ac6 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100ac6:	55                   	push   %ebp
f0100ac7:	89 e5                	mov    %esp,%ebp
f0100ac9:	53                   	push   %ebx
f0100aca:	83 ec 10             	sub    $0x10,%esp
f0100acd:	e8 ea f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100ad2:	81 c3 36 08 01 00    	add    $0x10836,%ebx
	cputchar(ch);
f0100ad8:	ff 75 08             	pushl  0x8(%ebp)
f0100adb:	e8 53 fc ff ff       	call   f0100733 <cputchar>
	*cnt++;
}
f0100ae0:	83 c4 10             	add    $0x10,%esp
f0100ae3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ae6:	c9                   	leave  
f0100ae7:	c3                   	ret    

f0100ae8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100ae8:	55                   	push   %ebp
f0100ae9:	89 e5                	mov    %esp,%ebp
f0100aeb:	53                   	push   %ebx
f0100aec:	83 ec 14             	sub    $0x14,%esp
f0100aef:	e8 c8 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100af4:	81 c3 14 08 01 00    	add    $0x10814,%ebx
	int cnt = 0;
f0100afa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b01:	ff 75 0c             	pushl  0xc(%ebp)
f0100b04:	ff 75 08             	pushl  0x8(%ebp)
f0100b07:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b0a:	50                   	push   %eax
f0100b0b:	8d 83 be f7 fe ff    	lea    -0x10842(%ebx),%eax
f0100b11:	50                   	push   %eax
f0100b12:	e8 8d 04 00 00       	call   f0100fa4 <vprintfmt>
	return cnt;
}
f0100b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b1d:	c9                   	leave  
f0100b1e:	c3                   	ret    

f0100b1f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b1f:	55                   	push   %ebp
f0100b20:	89 e5                	mov    %esp,%ebp
f0100b22:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b25:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b28:	50                   	push   %eax
f0100b29:	ff 75 08             	pushl  0x8(%ebp)
f0100b2c:	e8 b7 ff ff ff       	call   f0100ae8 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b31:	c9                   	leave  
f0100b32:	c3                   	ret    

f0100b33 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b33:	55                   	push   %ebp
f0100b34:	89 e5                	mov    %esp,%ebp
f0100b36:	57                   	push   %edi
f0100b37:	56                   	push   %esi
f0100b38:	53                   	push   %ebx
f0100b39:	83 ec 14             	sub    $0x14,%esp
f0100b3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b3f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b42:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b45:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b48:	8b 32                	mov    (%edx),%esi
f0100b4a:	8b 01                	mov    (%ecx),%eax
f0100b4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b4f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b56:	eb 2f                	jmp    f0100b87 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b58:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b5b:	39 c6                	cmp    %eax,%esi
f0100b5d:	7f 49                	jg     f0100ba8 <stab_binsearch+0x75>
f0100b5f:	0f b6 0a             	movzbl (%edx),%ecx
f0100b62:	83 ea 0c             	sub    $0xc,%edx
f0100b65:	39 f9                	cmp    %edi,%ecx
f0100b67:	75 ef                	jne    f0100b58 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b69:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b6c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b6f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b73:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b76:	73 35                	jae    f0100bad <stab_binsearch+0x7a>
			*region_left = m;
f0100b78:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b7b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100b7d:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100b80:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b87:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100b8a:	7f 4e                	jg     f0100bda <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b8f:	01 f0                	add    %esi,%eax
f0100b91:	89 c3                	mov    %eax,%ebx
f0100b93:	c1 eb 1f             	shr    $0x1f,%ebx
f0100b96:	01 c3                	add    %eax,%ebx
f0100b98:	d1 fb                	sar    %ebx
f0100b9a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b9d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100ba0:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100ba4:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100ba6:	eb b3                	jmp    f0100b5b <stab_binsearch+0x28>
			l = true_m + 1;
f0100ba8:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100bab:	eb da                	jmp    f0100b87 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100bad:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bb0:	76 14                	jbe    f0100bc6 <stab_binsearch+0x93>
			*region_right = m - 1;
f0100bb2:	83 e8 01             	sub    $0x1,%eax
f0100bb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bb8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100bbb:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100bbd:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bc4:	eb c1                	jmp    f0100b87 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100bc6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bc9:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100bcb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100bcf:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100bd1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bd8:	eb ad                	jmp    f0100b87 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100bda:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100bde:	74 16                	je     f0100bf6 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100be0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100be3:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100be5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100be8:	8b 0e                	mov    (%esi),%ecx
f0100bea:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bed:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100bf0:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100bf4:	eb 12                	jmp    f0100c08 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100bf6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bf9:	8b 00                	mov    (%eax),%eax
f0100bfb:	83 e8 01             	sub    $0x1,%eax
f0100bfe:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c01:	89 07                	mov    %eax,(%edi)
f0100c03:	eb 16                	jmp    f0100c1b <stab_binsearch+0xe8>
		     l--)
f0100c05:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100c08:	39 c1                	cmp    %eax,%ecx
f0100c0a:	7d 0a                	jge    f0100c16 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100c0c:	0f b6 1a             	movzbl (%edx),%ebx
f0100c0f:	83 ea 0c             	sub    $0xc,%edx
f0100c12:	39 fb                	cmp    %edi,%ebx
f0100c14:	75 ef                	jne    f0100c05 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100c16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c19:	89 07                	mov    %eax,(%edi)
	}
}
f0100c1b:	83 c4 14             	add    $0x14,%esp
f0100c1e:	5b                   	pop    %ebx
f0100c1f:	5e                   	pop    %esi
f0100c20:	5f                   	pop    %edi
f0100c21:	5d                   	pop    %ebp
f0100c22:	c3                   	ret    

f0100c23 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c23:	55                   	push   %ebp
f0100c24:	89 e5                	mov    %esp,%ebp
f0100c26:	57                   	push   %edi
f0100c27:	56                   	push   %esi
f0100c28:	53                   	push   %ebx
f0100c29:	83 ec 3c             	sub    $0x3c,%esp
f0100c2c:	e8 8b f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100c31:	81 c3 d7 06 01 00    	add    $0x106d7,%ebx
f0100c37:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100c3a:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c3d:	8d 83 7c 0d ff ff    	lea    -0xf284(%ebx),%eax
f0100c43:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100c45:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100c4c:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100c4f:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100c56:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100c59:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c60:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100c66:	0f 86 2f 01 00 00    	jbe    f0100d9b <debuginfo_eip+0x178>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c6c:	c7 c0 45 60 10 f0    	mov    $0xf0106045,%eax
f0100c72:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100c78:	0f 86 00 02 00 00    	jbe    f0100e7e <debuginfo_eip+0x25b>
f0100c7e:	c7 c0 cd 79 10 f0    	mov    $0xf01079cd,%eax
f0100c84:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c88:	0f 85 f7 01 00 00    	jne    f0100e85 <debuginfo_eip+0x262>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c8e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c95:	c7 c0 a0 22 10 f0    	mov    $0xf01022a0,%eax
f0100c9b:	c7 c2 44 60 10 f0    	mov    $0xf0106044,%edx
f0100ca1:	29 c2                	sub    %eax,%edx
f0100ca3:	c1 fa 02             	sar    $0x2,%edx
f0100ca6:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100cac:	83 ea 01             	sub    $0x1,%edx
f0100caf:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100cb2:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100cb5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100cb8:	83 ec 08             	sub    $0x8,%esp
f0100cbb:	57                   	push   %edi
f0100cbc:	6a 64                	push   $0x64
f0100cbe:	e8 70 fe ff ff       	call   f0100b33 <stab_binsearch>
	if (lfile == 0)
f0100cc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cc6:	83 c4 10             	add    $0x10,%esp
f0100cc9:	85 c0                	test   %eax,%eax
f0100ccb:	0f 84 bb 01 00 00    	je     f0100e8c <debuginfo_eip+0x269>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100cd1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100cd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cd7:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100cda:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100cdd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ce0:	83 ec 08             	sub    $0x8,%esp
f0100ce3:	57                   	push   %edi
f0100ce4:	6a 24                	push   $0x24
f0100ce6:	c7 c0 a0 22 10 f0    	mov    $0xf01022a0,%eax
f0100cec:	e8 42 fe ff ff       	call   f0100b33 <stab_binsearch>

	if (lfun <= rfun) {
f0100cf1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cf4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100cf7:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100cfa:	83 c4 10             	add    $0x10,%esp
f0100cfd:	39 c8                	cmp    %ecx,%eax
f0100cff:	0f 8f ae 00 00 00    	jg     f0100db3 <debuginfo_eip+0x190>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d05:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d08:	c7 c1 a0 22 10 f0    	mov    $0xf01022a0,%ecx
f0100d0e:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100d11:	8b 11                	mov    (%ecx),%edx
f0100d13:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100d16:	c7 c2 cd 79 10 f0    	mov    $0xf01079cd,%edx
f0100d1c:	81 ea 45 60 10 f0    	sub    $0xf0106045,%edx
f0100d22:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0100d25:	73 0c                	jae    f0100d33 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d27:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100d2a:	81 c2 45 60 10 f0    	add    $0xf0106045,%edx
f0100d30:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d33:	8b 51 08             	mov    0x8(%ecx),%edx
f0100d36:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100d39:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100d3b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d3e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100d41:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d44:	83 ec 08             	sub    $0x8,%esp
f0100d47:	6a 3a                	push   $0x3a
f0100d49:	ff 76 08             	pushl  0x8(%esi)
f0100d4c:	e8 f4 09 00 00       	call   f0101745 <strfind>
f0100d51:	2b 46 08             	sub    0x8(%esi),%eax
f0100d54:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d57:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d5a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d5d:	83 c4 08             	add    $0x8,%esp
f0100d60:	57                   	push   %edi
f0100d61:	6a 44                	push   $0x44
f0100d63:	c7 c7 a0 22 10 f0    	mov    $0xf01022a0,%edi
f0100d69:	89 f8                	mov    %edi,%eax
f0100d6b:	e8 c3 fd ff ff       	call   f0100b33 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0100d70:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d73:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d76:	c1 e2 02             	shl    $0x2,%edx
f0100d79:	0f b7 4c 3a 06       	movzwl 0x6(%edx,%edi,1),%ecx
f0100d7e:	89 4e 04             	mov    %ecx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d81:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100d84:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0100d88:	83 c4 10             	add    $0x10,%esp
f0100d8b:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f0100d8f:	bf 01 00 00 00       	mov    $0x1,%edi
f0100d94:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100d97:	89 ce                	mov    %ecx,%esi
f0100d99:	eb 34                	jmp    f0100dcf <debuginfo_eip+0x1ac>
  	        panic("User address");
f0100d9b:	83 ec 04             	sub    $0x4,%esp
f0100d9e:	8d 83 86 0d ff ff    	lea    -0xf27a(%ebx),%eax
f0100da4:	50                   	push   %eax
f0100da5:	6a 7f                	push   $0x7f
f0100da7:	8d 83 93 0d ff ff    	lea    -0xf26d(%ebx),%eax
f0100dad:	50                   	push   %eax
f0100dae:	e8 53 f3 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100db3:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100db6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100db9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100dbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100dbf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100dc2:	eb 80                	jmp    f0100d44 <debuginfo_eip+0x121>
f0100dc4:	83 e8 01             	sub    $0x1,%eax
f0100dc7:	83 ea 0c             	sub    $0xc,%edx
f0100dca:	89 f9                	mov    %edi,%ecx
f0100dcc:	88 4d c0             	mov    %cl,-0x40(%ebp)
f0100dcf:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f0100dd2:	39 c6                	cmp    %eax,%esi
f0100dd4:	7f 2a                	jg     f0100e00 <debuginfo_eip+0x1dd>
f0100dd6:	89 55 c4             	mov    %edx,-0x3c(%ebp)
	       && stabs[lline].n_type != N_SOL
f0100dd9:	0f b6 0a             	movzbl (%edx),%ecx
f0100ddc:	80 f9 84             	cmp    $0x84,%cl
f0100ddf:	74 49                	je     f0100e2a <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100de1:	80 f9 64             	cmp    $0x64,%cl
f0100de4:	75 de                	jne    f0100dc4 <debuginfo_eip+0x1a1>
f0100de6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0100de9:	83 79 04 00          	cmpl   $0x0,0x4(%ecx)
f0100ded:	74 d5                	je     f0100dc4 <debuginfo_eip+0x1a1>
f0100def:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100df2:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0100df6:	74 3b                	je     f0100e33 <debuginfo_eip+0x210>
f0100df8:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100dfb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100dfe:	eb 33                	jmp    f0100e33 <debuginfo_eip+0x210>
f0100e00:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e03:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e06:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e09:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100e0e:	39 fa                	cmp    %edi,%edx
f0100e10:	0f 8d 82 00 00 00    	jge    f0100e98 <debuginfo_eip+0x275>
		for (lline = lfun + 1;
f0100e16:	83 c2 01             	add    $0x1,%edx
f0100e19:	89 d0                	mov    %edx,%eax
f0100e1b:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100e1e:	c7 c2 a0 22 10 f0    	mov    $0xf01022a0,%edx
f0100e24:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100e28:	eb 3b                	jmp    f0100e65 <debuginfo_eip+0x242>
f0100e2a:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e2d:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0100e31:	75 26                	jne    f0100e59 <debuginfo_eip+0x236>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e33:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e36:	c7 c0 a0 22 10 f0    	mov    $0xf01022a0,%eax
f0100e3c:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e3f:	c7 c0 cd 79 10 f0    	mov    $0xf01079cd,%eax
f0100e45:	81 e8 45 60 10 f0    	sub    $0xf0106045,%eax
f0100e4b:	39 c2                	cmp    %eax,%edx
f0100e4d:	73 b4                	jae    f0100e03 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e4f:	81 c2 45 60 10 f0    	add    $0xf0106045,%edx
f0100e55:	89 16                	mov    %edx,(%esi)
f0100e57:	eb aa                	jmp    f0100e03 <debuginfo_eip+0x1e0>
f0100e59:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100e5c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e5f:	eb d2                	jmp    f0100e33 <debuginfo_eip+0x210>
			info->eip_fn_narg++;
f0100e61:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100e65:	39 c7                	cmp    %eax,%edi
f0100e67:	7e 2a                	jle    f0100e93 <debuginfo_eip+0x270>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e69:	0f b6 0a             	movzbl (%edx),%ecx
f0100e6c:	83 c0 01             	add    $0x1,%eax
f0100e6f:	83 c2 0c             	add    $0xc,%edx
f0100e72:	80 f9 a0             	cmp    $0xa0,%cl
f0100e75:	74 ea                	je     f0100e61 <debuginfo_eip+0x23e>
	return 0;
f0100e77:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e7c:	eb 1a                	jmp    f0100e98 <debuginfo_eip+0x275>
		return -1;
f0100e7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e83:	eb 13                	jmp    f0100e98 <debuginfo_eip+0x275>
f0100e85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e8a:	eb 0c                	jmp    f0100e98 <debuginfo_eip+0x275>
		return -1;
f0100e8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e91:	eb 05                	jmp    f0100e98 <debuginfo_eip+0x275>
	return 0;
f0100e93:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e98:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e9b:	5b                   	pop    %ebx
f0100e9c:	5e                   	pop    %esi
f0100e9d:	5f                   	pop    %edi
f0100e9e:	5d                   	pop    %ebp
f0100e9f:	c3                   	ret    

f0100ea0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ea0:	55                   	push   %ebp
f0100ea1:	89 e5                	mov    %esp,%ebp
f0100ea3:	57                   	push   %edi
f0100ea4:	56                   	push   %esi
f0100ea5:	53                   	push   %ebx
f0100ea6:	83 ec 2c             	sub    $0x2c,%esp
f0100ea9:	e8 3a 06 00 00       	call   f01014e8 <__x86.get_pc_thunk.cx>
f0100eae:	81 c1 5a 04 01 00    	add    $0x1045a,%ecx
f0100eb4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100eb7:	89 c7                	mov    %eax,%edi
f0100eb9:	89 d6                	mov    %edx,%esi
f0100ebb:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ebe:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ec1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ec4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ec7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100eca:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ecf:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100ed2:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100ed5:	39 d3                	cmp    %edx,%ebx
f0100ed7:	72 09                	jb     f0100ee2 <printnum+0x42>
f0100ed9:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100edc:	0f 87 83 00 00 00    	ja     f0100f65 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ee2:	83 ec 0c             	sub    $0xc,%esp
f0100ee5:	ff 75 18             	pushl  0x18(%ebp)
f0100ee8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eeb:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100eee:	53                   	push   %ebx
f0100eef:	ff 75 10             	pushl  0x10(%ebp)
f0100ef2:	83 ec 08             	sub    $0x8,%esp
f0100ef5:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ef8:	ff 75 d8             	pushl  -0x28(%ebp)
f0100efb:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100efe:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f01:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100f04:	e8 57 0a 00 00       	call   f0101960 <__udivdi3>
f0100f09:	83 c4 18             	add    $0x18,%esp
f0100f0c:	52                   	push   %edx
f0100f0d:	50                   	push   %eax
f0100f0e:	89 f2                	mov    %esi,%edx
f0100f10:	89 f8                	mov    %edi,%eax
f0100f12:	e8 89 ff ff ff       	call   f0100ea0 <printnum>
f0100f17:	83 c4 20             	add    $0x20,%esp
f0100f1a:	eb 13                	jmp    f0100f2f <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f1c:	83 ec 08             	sub    $0x8,%esp
f0100f1f:	56                   	push   %esi
f0100f20:	ff 75 18             	pushl  0x18(%ebp)
f0100f23:	ff d7                	call   *%edi
f0100f25:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f28:	83 eb 01             	sub    $0x1,%ebx
f0100f2b:	85 db                	test   %ebx,%ebx
f0100f2d:	7f ed                	jg     f0100f1c <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f2f:	83 ec 08             	sub    $0x8,%esp
f0100f32:	56                   	push   %esi
f0100f33:	83 ec 04             	sub    $0x4,%esp
f0100f36:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f39:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f3c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f3f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f42:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f45:	89 f3                	mov    %esi,%ebx
f0100f47:	e8 34 0b 00 00       	call   f0101a80 <__umoddi3>
f0100f4c:	83 c4 14             	add    $0x14,%esp
f0100f4f:	0f be 84 06 a1 0d ff 	movsbl -0xf25f(%esi,%eax,1),%eax
f0100f56:	ff 
f0100f57:	50                   	push   %eax
f0100f58:	ff d7                	call   *%edi
}
f0100f5a:	83 c4 10             	add    $0x10,%esp
f0100f5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f60:	5b                   	pop    %ebx
f0100f61:	5e                   	pop    %esi
f0100f62:	5f                   	pop    %edi
f0100f63:	5d                   	pop    %ebp
f0100f64:	c3                   	ret    
f0100f65:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100f68:	eb be                	jmp    f0100f28 <printnum+0x88>

f0100f6a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f6a:	55                   	push   %ebp
f0100f6b:	89 e5                	mov    %esp,%ebp
f0100f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f70:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f74:	8b 10                	mov    (%eax),%edx
f0100f76:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f79:	73 0a                	jae    f0100f85 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f7b:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f7e:	89 08                	mov    %ecx,(%eax)
f0100f80:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f83:	88 02                	mov    %al,(%edx)
}
f0100f85:	5d                   	pop    %ebp
f0100f86:	c3                   	ret    

f0100f87 <printfmt>:
{
f0100f87:	55                   	push   %ebp
f0100f88:	89 e5                	mov    %esp,%ebp
f0100f8a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f8d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f90:	50                   	push   %eax
f0100f91:	ff 75 10             	pushl  0x10(%ebp)
f0100f94:	ff 75 0c             	pushl  0xc(%ebp)
f0100f97:	ff 75 08             	pushl  0x8(%ebp)
f0100f9a:	e8 05 00 00 00       	call   f0100fa4 <vprintfmt>
}
f0100f9f:	83 c4 10             	add    $0x10,%esp
f0100fa2:	c9                   	leave  
f0100fa3:	c3                   	ret    

f0100fa4 <vprintfmt>:
{
f0100fa4:	55                   	push   %ebp
f0100fa5:	89 e5                	mov    %esp,%ebp
f0100fa7:	57                   	push   %edi
f0100fa8:	56                   	push   %esi
f0100fa9:	53                   	push   %ebx
f0100faa:	83 ec 2c             	sub    $0x2c,%esp
f0100fad:	e8 0a f2 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100fb2:	81 c3 56 03 01 00    	add    $0x10356,%ebx
f0100fb8:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100fbb:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100fbe:	e9 fb 03 00 00       	jmp    f01013be <.L35+0x48>
		padc = ' ';
f0100fc3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100fc7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100fce:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0100fd5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100fdc:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fe1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100fe4:	8d 47 01             	lea    0x1(%edi),%eax
f0100fe7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100fea:	0f b6 17             	movzbl (%edi),%edx
f0100fed:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100ff0:	3c 55                	cmp    $0x55,%al
f0100ff2:	0f 87 4e 04 00 00    	ja     f0101446 <.L22>
f0100ff8:	0f b6 c0             	movzbl %al,%eax
f0100ffb:	89 d9                	mov    %ebx,%ecx
f0100ffd:	03 8c 83 30 0e ff ff 	add    -0xf1d0(%ebx,%eax,4),%ecx
f0101004:	ff e1                	jmp    *%ecx

f0101006 <.L71>:
f0101006:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0101009:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010100d:	eb d5                	jmp    f0100fe4 <vprintfmt+0x40>

f010100f <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f010100f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0101012:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101016:	eb cc                	jmp    f0100fe4 <vprintfmt+0x40>

f0101018 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0101018:	0f b6 d2             	movzbl %dl,%edx
f010101b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010101e:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0101023:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101026:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010102a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010102d:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0101030:	83 f9 09             	cmp    $0x9,%ecx
f0101033:	77 55                	ja     f010108a <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0101035:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0101038:	eb e9                	jmp    f0101023 <.L29+0xb>

f010103a <.L26>:
			precision = va_arg(ap, int);
f010103a:	8b 45 14             	mov    0x14(%ebp),%eax
f010103d:	8b 00                	mov    (%eax),%eax
f010103f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101042:	8b 45 14             	mov    0x14(%ebp),%eax
f0101045:	8d 40 04             	lea    0x4(%eax),%eax
f0101048:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010104b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010104e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101052:	79 90                	jns    f0100fe4 <vprintfmt+0x40>
				width = precision, precision = -1;
f0101054:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101057:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010105a:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0101061:	eb 81                	jmp    f0100fe4 <vprintfmt+0x40>

f0101063 <.L27>:
f0101063:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101066:	85 c0                	test   %eax,%eax
f0101068:	ba 00 00 00 00       	mov    $0x0,%edx
f010106d:	0f 49 d0             	cmovns %eax,%edx
f0101070:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101073:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101076:	e9 69 ff ff ff       	jmp    f0100fe4 <vprintfmt+0x40>

f010107b <.L23>:
f010107b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f010107e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101085:	e9 5a ff ff ff       	jmp    f0100fe4 <vprintfmt+0x40>
f010108a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010108d:	eb bf                	jmp    f010104e <.L26+0x14>

f010108f <.L33>:
			lflag++;
f010108f:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101093:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0101096:	e9 49 ff ff ff       	jmp    f0100fe4 <vprintfmt+0x40>

f010109b <.L30>:
			putch(va_arg(ap, int), putdat);
f010109b:	8b 45 14             	mov    0x14(%ebp),%eax
f010109e:	8d 78 04             	lea    0x4(%eax),%edi
f01010a1:	83 ec 08             	sub    $0x8,%esp
f01010a4:	56                   	push   %esi
f01010a5:	ff 30                	pushl  (%eax)
f01010a7:	ff 55 08             	call   *0x8(%ebp)
			break;
f01010aa:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01010ad:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01010b0:	e9 06 03 00 00       	jmp    f01013bb <.L35+0x45>

f01010b5 <.L32>:
			err = va_arg(ap, int);
f01010b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01010b8:	8d 78 04             	lea    0x4(%eax),%edi
f01010bb:	8b 00                	mov    (%eax),%eax
f01010bd:	99                   	cltd   
f01010be:	31 d0                	xor    %edx,%eax
f01010c0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01010c2:	83 f8 06             	cmp    $0x6,%eax
f01010c5:	7f 27                	jg     f01010ee <.L32+0x39>
f01010c7:	8b 94 83 20 1d 00 00 	mov    0x1d20(%ebx,%eax,4),%edx
f01010ce:	85 d2                	test   %edx,%edx
f01010d0:	74 1c                	je     f01010ee <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f01010d2:	52                   	push   %edx
f01010d3:	8d 83 c2 0d ff ff    	lea    -0xf23e(%ebx),%eax
f01010d9:	50                   	push   %eax
f01010da:	56                   	push   %esi
f01010db:	ff 75 08             	pushl  0x8(%ebp)
f01010de:	e8 a4 fe ff ff       	call   f0100f87 <printfmt>
f01010e3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010e6:	89 7d 14             	mov    %edi,0x14(%ebp)
f01010e9:	e9 cd 02 00 00       	jmp    f01013bb <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f01010ee:	50                   	push   %eax
f01010ef:	8d 83 b9 0d ff ff    	lea    -0xf247(%ebx),%eax
f01010f5:	50                   	push   %eax
f01010f6:	56                   	push   %esi
f01010f7:	ff 75 08             	pushl  0x8(%ebp)
f01010fa:	e8 88 fe ff ff       	call   f0100f87 <printfmt>
f01010ff:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101102:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101105:	e9 b1 02 00 00       	jmp    f01013bb <.L35+0x45>

f010110a <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f010110a:	8b 45 14             	mov    0x14(%ebp),%eax
f010110d:	83 c0 04             	add    $0x4,%eax
f0101110:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101113:	8b 45 14             	mov    0x14(%ebp),%eax
f0101116:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0101118:	85 ff                	test   %edi,%edi
f010111a:	8d 83 b2 0d ff ff    	lea    -0xf24e(%ebx),%eax
f0101120:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0101123:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101127:	0f 8e b5 00 00 00    	jle    f01011e2 <.L36+0xd8>
f010112d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101131:	75 08                	jne    f010113b <.L36+0x31>
f0101133:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101136:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101139:	eb 6d                	jmp    f01011a8 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f010113b:	83 ec 08             	sub    $0x8,%esp
f010113e:	ff 75 cc             	pushl  -0x34(%ebp)
f0101141:	57                   	push   %edi
f0101142:	e8 ba 04 00 00       	call   f0101601 <strnlen>
f0101147:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010114a:	29 c2                	sub    %eax,%edx
f010114c:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010114f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101152:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101156:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101159:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010115c:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f010115e:	eb 10                	jmp    f0101170 <.L36+0x66>
					putch(padc, putdat);
f0101160:	83 ec 08             	sub    $0x8,%esp
f0101163:	56                   	push   %esi
f0101164:	ff 75 e0             	pushl  -0x20(%ebp)
f0101167:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010116a:	83 ef 01             	sub    $0x1,%edi
f010116d:	83 c4 10             	add    $0x10,%esp
f0101170:	85 ff                	test   %edi,%edi
f0101172:	7f ec                	jg     f0101160 <.L36+0x56>
f0101174:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101177:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010117a:	85 d2                	test   %edx,%edx
f010117c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101181:	0f 49 c2             	cmovns %edx,%eax
f0101184:	29 c2                	sub    %eax,%edx
f0101186:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101189:	89 75 0c             	mov    %esi,0xc(%ebp)
f010118c:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010118f:	eb 17                	jmp    f01011a8 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f0101191:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101195:	75 30                	jne    f01011c7 <.L36+0xbd>
					putch(ch, putdat);
f0101197:	83 ec 08             	sub    $0x8,%esp
f010119a:	ff 75 0c             	pushl  0xc(%ebp)
f010119d:	50                   	push   %eax
f010119e:	ff 55 08             	call   *0x8(%ebp)
f01011a1:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011a4:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01011a8:	83 c7 01             	add    $0x1,%edi
f01011ab:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01011af:	0f be c2             	movsbl %dl,%eax
f01011b2:	85 c0                	test   %eax,%eax
f01011b4:	74 52                	je     f0101208 <.L36+0xfe>
f01011b6:	85 f6                	test   %esi,%esi
f01011b8:	78 d7                	js     f0101191 <.L36+0x87>
f01011ba:	83 ee 01             	sub    $0x1,%esi
f01011bd:	79 d2                	jns    f0101191 <.L36+0x87>
f01011bf:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011c2:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01011c5:	eb 32                	jmp    f01011f9 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f01011c7:	0f be d2             	movsbl %dl,%edx
f01011ca:	83 ea 20             	sub    $0x20,%edx
f01011cd:	83 fa 5e             	cmp    $0x5e,%edx
f01011d0:	76 c5                	jbe    f0101197 <.L36+0x8d>
					putch('?', putdat);
f01011d2:	83 ec 08             	sub    $0x8,%esp
f01011d5:	ff 75 0c             	pushl  0xc(%ebp)
f01011d8:	6a 3f                	push   $0x3f
f01011da:	ff 55 08             	call   *0x8(%ebp)
f01011dd:	83 c4 10             	add    $0x10,%esp
f01011e0:	eb c2                	jmp    f01011a4 <.L36+0x9a>
f01011e2:	89 75 0c             	mov    %esi,0xc(%ebp)
f01011e5:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01011e8:	eb be                	jmp    f01011a8 <.L36+0x9e>
				putch(' ', putdat);
f01011ea:	83 ec 08             	sub    $0x8,%esp
f01011ed:	56                   	push   %esi
f01011ee:	6a 20                	push   $0x20
f01011f0:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f01011f3:	83 ef 01             	sub    $0x1,%edi
f01011f6:	83 c4 10             	add    $0x10,%esp
f01011f9:	85 ff                	test   %edi,%edi
f01011fb:	7f ed                	jg     f01011ea <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f01011fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101200:	89 45 14             	mov    %eax,0x14(%ebp)
f0101203:	e9 b3 01 00 00       	jmp    f01013bb <.L35+0x45>
f0101208:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010120b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010120e:	eb e9                	jmp    f01011f9 <.L36+0xef>

f0101210 <.L31>:
f0101210:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101213:	83 f9 01             	cmp    $0x1,%ecx
f0101216:	7e 40                	jle    f0101258 <.L31+0x48>
		return va_arg(*ap, long long);
f0101218:	8b 45 14             	mov    0x14(%ebp),%eax
f010121b:	8b 50 04             	mov    0x4(%eax),%edx
f010121e:	8b 00                	mov    (%eax),%eax
f0101220:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101223:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101226:	8b 45 14             	mov    0x14(%ebp),%eax
f0101229:	8d 40 08             	lea    0x8(%eax),%eax
f010122c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010122f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101233:	79 55                	jns    f010128a <.L31+0x7a>
				putch('-', putdat);
f0101235:	83 ec 08             	sub    $0x8,%esp
f0101238:	56                   	push   %esi
f0101239:	6a 2d                	push   $0x2d
f010123b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010123e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101241:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101244:	f7 da                	neg    %edx
f0101246:	83 d1 00             	adc    $0x0,%ecx
f0101249:	f7 d9                	neg    %ecx
f010124b:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010124e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101253:	e9 48 01 00 00       	jmp    f01013a0 <.L35+0x2a>
	else if (lflag)
f0101258:	85 c9                	test   %ecx,%ecx
f010125a:	75 17                	jne    f0101273 <.L31+0x63>
		return va_arg(*ap, int);
f010125c:	8b 45 14             	mov    0x14(%ebp),%eax
f010125f:	8b 00                	mov    (%eax),%eax
f0101261:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101264:	99                   	cltd   
f0101265:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101268:	8b 45 14             	mov    0x14(%ebp),%eax
f010126b:	8d 40 04             	lea    0x4(%eax),%eax
f010126e:	89 45 14             	mov    %eax,0x14(%ebp)
f0101271:	eb bc                	jmp    f010122f <.L31+0x1f>
		return va_arg(*ap, long);
f0101273:	8b 45 14             	mov    0x14(%ebp),%eax
f0101276:	8b 00                	mov    (%eax),%eax
f0101278:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010127b:	99                   	cltd   
f010127c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010127f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101282:	8d 40 04             	lea    0x4(%eax),%eax
f0101285:	89 45 14             	mov    %eax,0x14(%ebp)
f0101288:	eb a5                	jmp    f010122f <.L31+0x1f>
			num = getint(&ap, lflag);
f010128a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010128d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0101290:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101295:	e9 06 01 00 00       	jmp    f01013a0 <.L35+0x2a>

f010129a <.L37>:
f010129a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010129d:	83 f9 01             	cmp    $0x1,%ecx
f01012a0:	7e 18                	jle    f01012ba <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f01012a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01012a5:	8b 10                	mov    (%eax),%edx
f01012a7:	8b 48 04             	mov    0x4(%eax),%ecx
f01012aa:	8d 40 08             	lea    0x8(%eax),%eax
f01012ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012b0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012b5:	e9 e6 00 00 00       	jmp    f01013a0 <.L35+0x2a>
	else if (lflag)
f01012ba:	85 c9                	test   %ecx,%ecx
f01012bc:	75 1a                	jne    f01012d8 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f01012be:	8b 45 14             	mov    0x14(%ebp),%eax
f01012c1:	8b 10                	mov    (%eax),%edx
f01012c3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012c8:	8d 40 04             	lea    0x4(%eax),%eax
f01012cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012ce:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012d3:	e9 c8 00 00 00       	jmp    f01013a0 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01012d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01012db:	8b 10                	mov    (%eax),%edx
f01012dd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012e2:	8d 40 04             	lea    0x4(%eax),%eax
f01012e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012e8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012ed:	e9 ae 00 00 00       	jmp    f01013a0 <.L35+0x2a>

f01012f2 <.L34>:
f01012f2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01012f5:	83 f9 01             	cmp    $0x1,%ecx
f01012f8:	7e 3d                	jle    f0101337 <.L34+0x45>
		return va_arg(*ap, long long);
f01012fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01012fd:	8b 50 04             	mov    0x4(%eax),%edx
f0101300:	8b 00                	mov    (%eax),%eax
f0101302:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101305:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101308:	8b 45 14             	mov    0x14(%ebp),%eax
f010130b:	8d 40 08             	lea    0x8(%eax),%eax
f010130e:	89 45 14             	mov    %eax,0x14(%ebp)
                        if ((long long) num < 0) {
f0101311:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101315:	79 52                	jns    f0101369 <.L34+0x77>
                                putch('-', putdat);
f0101317:	83 ec 08             	sub    $0x8,%esp
f010131a:	56                   	push   %esi
f010131b:	6a 2d                	push   $0x2d
f010131d:	ff 55 08             	call   *0x8(%ebp)
                                num = -(long long) num;
f0101320:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101323:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101326:	f7 da                	neg    %edx
f0101328:	83 d1 00             	adc    $0x0,%ecx
f010132b:	f7 d9                	neg    %ecx
f010132d:	83 c4 10             	add    $0x10,%esp
                        base = 8;
f0101330:	b8 08 00 00 00       	mov    $0x8,%eax
f0101335:	eb 69                	jmp    f01013a0 <.L35+0x2a>
	else if (lflag)
f0101337:	85 c9                	test   %ecx,%ecx
f0101339:	75 17                	jne    f0101352 <.L34+0x60>
		return va_arg(*ap, int);
f010133b:	8b 45 14             	mov    0x14(%ebp),%eax
f010133e:	8b 00                	mov    (%eax),%eax
f0101340:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101343:	99                   	cltd   
f0101344:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101347:	8b 45 14             	mov    0x14(%ebp),%eax
f010134a:	8d 40 04             	lea    0x4(%eax),%eax
f010134d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101350:	eb bf                	jmp    f0101311 <.L34+0x1f>
		return va_arg(*ap, long);
f0101352:	8b 45 14             	mov    0x14(%ebp),%eax
f0101355:	8b 00                	mov    (%eax),%eax
f0101357:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010135a:	99                   	cltd   
f010135b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010135e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101361:	8d 40 04             	lea    0x4(%eax),%eax
f0101364:	89 45 14             	mov    %eax,0x14(%ebp)
f0101367:	eb a8                	jmp    f0101311 <.L34+0x1f>
                        num = getint(&ap, lflag);
f0101369:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010136c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
                        base = 8;
f010136f:	b8 08 00 00 00       	mov    $0x8,%eax
f0101374:	eb 2a                	jmp    f01013a0 <.L35+0x2a>

f0101376 <.L35>:
			putch('0', putdat);
f0101376:	83 ec 08             	sub    $0x8,%esp
f0101379:	56                   	push   %esi
f010137a:	6a 30                	push   $0x30
f010137c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010137f:	83 c4 08             	add    $0x8,%esp
f0101382:	56                   	push   %esi
f0101383:	6a 78                	push   $0x78
f0101385:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0101388:	8b 45 14             	mov    0x14(%ebp),%eax
f010138b:	8b 10                	mov    (%eax),%edx
f010138d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0101392:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101395:	8d 40 04             	lea    0x4(%eax),%eax
f0101398:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010139b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01013a0:	83 ec 0c             	sub    $0xc,%esp
f01013a3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01013a7:	57                   	push   %edi
f01013a8:	ff 75 e0             	pushl  -0x20(%ebp)
f01013ab:	50                   	push   %eax
f01013ac:	51                   	push   %ecx
f01013ad:	52                   	push   %edx
f01013ae:	89 f2                	mov    %esi,%edx
f01013b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01013b3:	e8 e8 fa ff ff       	call   f0100ea0 <printnum>
			break;
f01013b8:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01013bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01013be:	83 c7 01             	add    $0x1,%edi
f01013c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01013c5:	83 f8 25             	cmp    $0x25,%eax
f01013c8:	0f 84 f5 fb ff ff    	je     f0100fc3 <vprintfmt+0x1f>
			if (ch == '\0')
f01013ce:	85 c0                	test   %eax,%eax
f01013d0:	0f 84 91 00 00 00    	je     f0101467 <.L22+0x21>
			putch(ch, putdat);
f01013d6:	83 ec 08             	sub    $0x8,%esp
f01013d9:	56                   	push   %esi
f01013da:	50                   	push   %eax
f01013db:	ff 55 08             	call   *0x8(%ebp)
f01013de:	83 c4 10             	add    $0x10,%esp
f01013e1:	eb db                	jmp    f01013be <.L35+0x48>

f01013e3 <.L38>:
f01013e3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01013e6:	83 f9 01             	cmp    $0x1,%ecx
f01013e9:	7e 15                	jle    f0101400 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f01013eb:	8b 45 14             	mov    0x14(%ebp),%eax
f01013ee:	8b 10                	mov    (%eax),%edx
f01013f0:	8b 48 04             	mov    0x4(%eax),%ecx
f01013f3:	8d 40 08             	lea    0x8(%eax),%eax
f01013f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013f9:	b8 10 00 00 00       	mov    $0x10,%eax
f01013fe:	eb a0                	jmp    f01013a0 <.L35+0x2a>
	else if (lflag)
f0101400:	85 c9                	test   %ecx,%ecx
f0101402:	75 17                	jne    f010141b <.L38+0x38>
		return va_arg(*ap, unsigned int);
f0101404:	8b 45 14             	mov    0x14(%ebp),%eax
f0101407:	8b 10                	mov    (%eax),%edx
f0101409:	b9 00 00 00 00       	mov    $0x0,%ecx
f010140e:	8d 40 04             	lea    0x4(%eax),%eax
f0101411:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101414:	b8 10 00 00 00       	mov    $0x10,%eax
f0101419:	eb 85                	jmp    f01013a0 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f010141b:	8b 45 14             	mov    0x14(%ebp),%eax
f010141e:	8b 10                	mov    (%eax),%edx
f0101420:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101425:	8d 40 04             	lea    0x4(%eax),%eax
f0101428:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010142b:	b8 10 00 00 00       	mov    $0x10,%eax
f0101430:	e9 6b ff ff ff       	jmp    f01013a0 <.L35+0x2a>

f0101435 <.L25>:
			putch(ch, putdat);
f0101435:	83 ec 08             	sub    $0x8,%esp
f0101438:	56                   	push   %esi
f0101439:	6a 25                	push   $0x25
f010143b:	ff 55 08             	call   *0x8(%ebp)
			break;
f010143e:	83 c4 10             	add    $0x10,%esp
f0101441:	e9 75 ff ff ff       	jmp    f01013bb <.L35+0x45>

f0101446 <.L22>:
			putch('%', putdat);
f0101446:	83 ec 08             	sub    $0x8,%esp
f0101449:	56                   	push   %esi
f010144a:	6a 25                	push   $0x25
f010144c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010144f:	83 c4 10             	add    $0x10,%esp
f0101452:	89 f8                	mov    %edi,%eax
f0101454:	eb 03                	jmp    f0101459 <.L22+0x13>
f0101456:	83 e8 01             	sub    $0x1,%eax
f0101459:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010145d:	75 f7                	jne    f0101456 <.L22+0x10>
f010145f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101462:	e9 54 ff ff ff       	jmp    f01013bb <.L35+0x45>
}
f0101467:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010146a:	5b                   	pop    %ebx
f010146b:	5e                   	pop    %esi
f010146c:	5f                   	pop    %edi
f010146d:	5d                   	pop    %ebp
f010146e:	c3                   	ret    

f010146f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010146f:	55                   	push   %ebp
f0101470:	89 e5                	mov    %esp,%ebp
f0101472:	53                   	push   %ebx
f0101473:	83 ec 14             	sub    $0x14,%esp
f0101476:	e8 41 ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010147b:	81 c3 8d fe 00 00    	add    $0xfe8d,%ebx
f0101481:	8b 45 08             	mov    0x8(%ebp),%eax
f0101484:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101487:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010148a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010148e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101491:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101498:	85 c0                	test   %eax,%eax
f010149a:	74 2b                	je     f01014c7 <vsnprintf+0x58>
f010149c:	85 d2                	test   %edx,%edx
f010149e:	7e 27                	jle    f01014c7 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01014a0:	ff 75 14             	pushl  0x14(%ebp)
f01014a3:	ff 75 10             	pushl  0x10(%ebp)
f01014a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01014a9:	50                   	push   %eax
f01014aa:	8d 83 62 fc fe ff    	lea    -0x1039e(%ebx),%eax
f01014b0:	50                   	push   %eax
f01014b1:	e8 ee fa ff ff       	call   f0100fa4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01014b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01014b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01014bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01014bf:	83 c4 10             	add    $0x10,%esp
}
f01014c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014c5:	c9                   	leave  
f01014c6:	c3                   	ret    
		return -E_INVAL;
f01014c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01014cc:	eb f4                	jmp    f01014c2 <vsnprintf+0x53>

f01014ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01014ce:	55                   	push   %ebp
f01014cf:	89 e5                	mov    %esp,%ebp
f01014d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01014d4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01014d7:	50                   	push   %eax
f01014d8:	ff 75 10             	pushl  0x10(%ebp)
f01014db:	ff 75 0c             	pushl  0xc(%ebp)
f01014de:	ff 75 08             	pushl  0x8(%ebp)
f01014e1:	e8 89 ff ff ff       	call   f010146f <vsnprintf>
	va_end(ap);

	return rc;
}
f01014e6:	c9                   	leave  
f01014e7:	c3                   	ret    

f01014e8 <__x86.get_pc_thunk.cx>:
f01014e8:	8b 0c 24             	mov    (%esp),%ecx
f01014eb:	c3                   	ret    

f01014ec <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014ec:	55                   	push   %ebp
f01014ed:	89 e5                	mov    %esp,%ebp
f01014ef:	57                   	push   %edi
f01014f0:	56                   	push   %esi
f01014f1:	53                   	push   %ebx
f01014f2:	83 ec 1c             	sub    $0x1c,%esp
f01014f5:	e8 c2 ec ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01014fa:	81 c3 0e fe 00 00    	add    $0xfe0e,%ebx
f0101500:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101503:	85 c0                	test   %eax,%eax
f0101505:	74 13                	je     f010151a <readline+0x2e>
		cprintf("%s", prompt);
f0101507:	83 ec 08             	sub    $0x8,%esp
f010150a:	50                   	push   %eax
f010150b:	8d 83 c2 0d ff ff    	lea    -0xf23e(%ebx),%eax
f0101511:	50                   	push   %eax
f0101512:	e8 08 f6 ff ff       	call   f0100b1f <cprintf>
f0101517:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010151a:	83 ec 0c             	sub    $0xc,%esp
f010151d:	6a 00                	push   $0x0
f010151f:	e8 30 f2 ff ff       	call   f0100754 <iscons>
f0101524:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101527:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010152a:	bf 00 00 00 00       	mov    $0x0,%edi
f010152f:	eb 46                	jmp    f0101577 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0101531:	83 ec 08             	sub    $0x8,%esp
f0101534:	50                   	push   %eax
f0101535:	8d 83 88 0f ff ff    	lea    -0xf078(%ebx),%eax
f010153b:	50                   	push   %eax
f010153c:	e8 de f5 ff ff       	call   f0100b1f <cprintf>
			return NULL;
f0101541:	83 c4 10             	add    $0x10,%esp
f0101544:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101549:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010154c:	5b                   	pop    %ebx
f010154d:	5e                   	pop    %esi
f010154e:	5f                   	pop    %edi
f010154f:	5d                   	pop    %ebp
f0101550:	c3                   	ret    
			if (echoing)
f0101551:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101555:	75 05                	jne    f010155c <readline+0x70>
			i--;
f0101557:	83 ef 01             	sub    $0x1,%edi
f010155a:	eb 1b                	jmp    f0101577 <readline+0x8b>
				cputchar('\b');
f010155c:	83 ec 0c             	sub    $0xc,%esp
f010155f:	6a 08                	push   $0x8
f0101561:	e8 cd f1 ff ff       	call   f0100733 <cputchar>
f0101566:	83 c4 10             	add    $0x10,%esp
f0101569:	eb ec                	jmp    f0101557 <readline+0x6b>
			buf[i++] = c;
f010156b:	89 f0                	mov    %esi,%eax
f010156d:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f0101574:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0101577:	e8 c7 f1 ff ff       	call   f0100743 <getchar>
f010157c:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f010157e:	85 c0                	test   %eax,%eax
f0101580:	78 af                	js     f0101531 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101582:	83 f8 08             	cmp    $0x8,%eax
f0101585:	0f 94 c2             	sete   %dl
f0101588:	83 f8 7f             	cmp    $0x7f,%eax
f010158b:	0f 94 c0             	sete   %al
f010158e:	08 c2                	or     %al,%dl
f0101590:	74 04                	je     f0101596 <readline+0xaa>
f0101592:	85 ff                	test   %edi,%edi
f0101594:	7f bb                	jg     f0101551 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101596:	83 fe 1f             	cmp    $0x1f,%esi
f0101599:	7e 1c                	jle    f01015b7 <readline+0xcb>
f010159b:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01015a1:	7f 14                	jg     f01015b7 <readline+0xcb>
			if (echoing)
f01015a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015a7:	74 c2                	je     f010156b <readline+0x7f>
				cputchar(c);
f01015a9:	83 ec 0c             	sub    $0xc,%esp
f01015ac:	56                   	push   %esi
f01015ad:	e8 81 f1 ff ff       	call   f0100733 <cputchar>
f01015b2:	83 c4 10             	add    $0x10,%esp
f01015b5:	eb b4                	jmp    f010156b <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f01015b7:	83 fe 0a             	cmp    $0xa,%esi
f01015ba:	74 05                	je     f01015c1 <readline+0xd5>
f01015bc:	83 fe 0d             	cmp    $0xd,%esi
f01015bf:	75 b6                	jne    f0101577 <readline+0x8b>
			if (echoing)
f01015c1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015c5:	75 13                	jne    f01015da <readline+0xee>
			buf[i] = 0;
f01015c7:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f01015ce:	00 
			return buf;
f01015cf:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f01015d5:	e9 6f ff ff ff       	jmp    f0101549 <readline+0x5d>
				cputchar('\n');
f01015da:	83 ec 0c             	sub    $0xc,%esp
f01015dd:	6a 0a                	push   $0xa
f01015df:	e8 4f f1 ff ff       	call   f0100733 <cputchar>
f01015e4:	83 c4 10             	add    $0x10,%esp
f01015e7:	eb de                	jmp    f01015c7 <readline+0xdb>

f01015e9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01015e9:	55                   	push   %ebp
f01015ea:	89 e5                	mov    %esp,%ebp
f01015ec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01015ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01015f4:	eb 03                	jmp    f01015f9 <strlen+0x10>
		n++;
f01015f6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01015f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01015fd:	75 f7                	jne    f01015f6 <strlen+0xd>
	return n;
}
f01015ff:	5d                   	pop    %ebp
f0101600:	c3                   	ret    

f0101601 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101601:	55                   	push   %ebp
f0101602:	89 e5                	mov    %esp,%ebp
f0101604:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101607:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010160a:	b8 00 00 00 00       	mov    $0x0,%eax
f010160f:	eb 03                	jmp    f0101614 <strnlen+0x13>
		n++;
f0101611:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101614:	39 d0                	cmp    %edx,%eax
f0101616:	74 06                	je     f010161e <strnlen+0x1d>
f0101618:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010161c:	75 f3                	jne    f0101611 <strnlen+0x10>
	return n;
}
f010161e:	5d                   	pop    %ebp
f010161f:	c3                   	ret    

f0101620 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101620:	55                   	push   %ebp
f0101621:	89 e5                	mov    %esp,%ebp
f0101623:	53                   	push   %ebx
f0101624:	8b 45 08             	mov    0x8(%ebp),%eax
f0101627:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010162a:	89 c2                	mov    %eax,%edx
f010162c:	83 c1 01             	add    $0x1,%ecx
f010162f:	83 c2 01             	add    $0x1,%edx
f0101632:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101636:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101639:	84 db                	test   %bl,%bl
f010163b:	75 ef                	jne    f010162c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010163d:	5b                   	pop    %ebx
f010163e:	5d                   	pop    %ebp
f010163f:	c3                   	ret    

f0101640 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101640:	55                   	push   %ebp
f0101641:	89 e5                	mov    %esp,%ebp
f0101643:	53                   	push   %ebx
f0101644:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101647:	53                   	push   %ebx
f0101648:	e8 9c ff ff ff       	call   f01015e9 <strlen>
f010164d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101650:	ff 75 0c             	pushl  0xc(%ebp)
f0101653:	01 d8                	add    %ebx,%eax
f0101655:	50                   	push   %eax
f0101656:	e8 c5 ff ff ff       	call   f0101620 <strcpy>
	return dst;
}
f010165b:	89 d8                	mov    %ebx,%eax
f010165d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101660:	c9                   	leave  
f0101661:	c3                   	ret    

f0101662 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101662:	55                   	push   %ebp
f0101663:	89 e5                	mov    %esp,%ebp
f0101665:	56                   	push   %esi
f0101666:	53                   	push   %ebx
f0101667:	8b 75 08             	mov    0x8(%ebp),%esi
f010166a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010166d:	89 f3                	mov    %esi,%ebx
f010166f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101672:	89 f2                	mov    %esi,%edx
f0101674:	eb 0f                	jmp    f0101685 <strncpy+0x23>
		*dst++ = *src;
f0101676:	83 c2 01             	add    $0x1,%edx
f0101679:	0f b6 01             	movzbl (%ecx),%eax
f010167c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010167f:	80 39 01             	cmpb   $0x1,(%ecx)
f0101682:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0101685:	39 da                	cmp    %ebx,%edx
f0101687:	75 ed                	jne    f0101676 <strncpy+0x14>
	}
	return ret;
}
f0101689:	89 f0                	mov    %esi,%eax
f010168b:	5b                   	pop    %ebx
f010168c:	5e                   	pop    %esi
f010168d:	5d                   	pop    %ebp
f010168e:	c3                   	ret    

f010168f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010168f:	55                   	push   %ebp
f0101690:	89 e5                	mov    %esp,%ebp
f0101692:	56                   	push   %esi
f0101693:	53                   	push   %ebx
f0101694:	8b 75 08             	mov    0x8(%ebp),%esi
f0101697:	8b 55 0c             	mov    0xc(%ebp),%edx
f010169a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010169d:	89 f0                	mov    %esi,%eax
f010169f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01016a3:	85 c9                	test   %ecx,%ecx
f01016a5:	75 0b                	jne    f01016b2 <strlcpy+0x23>
f01016a7:	eb 17                	jmp    f01016c0 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01016a9:	83 c2 01             	add    $0x1,%edx
f01016ac:	83 c0 01             	add    $0x1,%eax
f01016af:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01016b2:	39 d8                	cmp    %ebx,%eax
f01016b4:	74 07                	je     f01016bd <strlcpy+0x2e>
f01016b6:	0f b6 0a             	movzbl (%edx),%ecx
f01016b9:	84 c9                	test   %cl,%cl
f01016bb:	75 ec                	jne    f01016a9 <strlcpy+0x1a>
		*dst = '\0';
f01016bd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01016c0:	29 f0                	sub    %esi,%eax
}
f01016c2:	5b                   	pop    %ebx
f01016c3:	5e                   	pop    %esi
f01016c4:	5d                   	pop    %ebp
f01016c5:	c3                   	ret    

f01016c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01016c6:	55                   	push   %ebp
f01016c7:	89 e5                	mov    %esp,%ebp
f01016c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01016cf:	eb 06                	jmp    f01016d7 <strcmp+0x11>
		p++, q++;
f01016d1:	83 c1 01             	add    $0x1,%ecx
f01016d4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01016d7:	0f b6 01             	movzbl (%ecx),%eax
f01016da:	84 c0                	test   %al,%al
f01016dc:	74 04                	je     f01016e2 <strcmp+0x1c>
f01016de:	3a 02                	cmp    (%edx),%al
f01016e0:	74 ef                	je     f01016d1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01016e2:	0f b6 c0             	movzbl %al,%eax
f01016e5:	0f b6 12             	movzbl (%edx),%edx
f01016e8:	29 d0                	sub    %edx,%eax
}
f01016ea:	5d                   	pop    %ebp
f01016eb:	c3                   	ret    

f01016ec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01016ec:	55                   	push   %ebp
f01016ed:	89 e5                	mov    %esp,%ebp
f01016ef:	53                   	push   %ebx
f01016f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01016f3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016f6:	89 c3                	mov    %eax,%ebx
f01016f8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01016fb:	eb 06                	jmp    f0101703 <strncmp+0x17>
		n--, p++, q++;
f01016fd:	83 c0 01             	add    $0x1,%eax
f0101700:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101703:	39 d8                	cmp    %ebx,%eax
f0101705:	74 16                	je     f010171d <strncmp+0x31>
f0101707:	0f b6 08             	movzbl (%eax),%ecx
f010170a:	84 c9                	test   %cl,%cl
f010170c:	74 04                	je     f0101712 <strncmp+0x26>
f010170e:	3a 0a                	cmp    (%edx),%cl
f0101710:	74 eb                	je     f01016fd <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101712:	0f b6 00             	movzbl (%eax),%eax
f0101715:	0f b6 12             	movzbl (%edx),%edx
f0101718:	29 d0                	sub    %edx,%eax
}
f010171a:	5b                   	pop    %ebx
f010171b:	5d                   	pop    %ebp
f010171c:	c3                   	ret    
		return 0;
f010171d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101722:	eb f6                	jmp    f010171a <strncmp+0x2e>

f0101724 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101724:	55                   	push   %ebp
f0101725:	89 e5                	mov    %esp,%ebp
f0101727:	8b 45 08             	mov    0x8(%ebp),%eax
f010172a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010172e:	0f b6 10             	movzbl (%eax),%edx
f0101731:	84 d2                	test   %dl,%dl
f0101733:	74 09                	je     f010173e <strchr+0x1a>
		if (*s == c)
f0101735:	38 ca                	cmp    %cl,%dl
f0101737:	74 0a                	je     f0101743 <strchr+0x1f>
	for (; *s; s++)
f0101739:	83 c0 01             	add    $0x1,%eax
f010173c:	eb f0                	jmp    f010172e <strchr+0xa>
			return (char *) s;
	return 0;
f010173e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101743:	5d                   	pop    %ebp
f0101744:	c3                   	ret    

f0101745 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101745:	55                   	push   %ebp
f0101746:	89 e5                	mov    %esp,%ebp
f0101748:	8b 45 08             	mov    0x8(%ebp),%eax
f010174b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010174f:	eb 03                	jmp    f0101754 <strfind+0xf>
f0101751:	83 c0 01             	add    $0x1,%eax
f0101754:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101757:	38 ca                	cmp    %cl,%dl
f0101759:	74 04                	je     f010175f <strfind+0x1a>
f010175b:	84 d2                	test   %dl,%dl
f010175d:	75 f2                	jne    f0101751 <strfind+0xc>
			break;
	return (char *) s;
}
f010175f:	5d                   	pop    %ebp
f0101760:	c3                   	ret    

f0101761 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101761:	55                   	push   %ebp
f0101762:	89 e5                	mov    %esp,%ebp
f0101764:	57                   	push   %edi
f0101765:	56                   	push   %esi
f0101766:	53                   	push   %ebx
f0101767:	8b 7d 08             	mov    0x8(%ebp),%edi
f010176a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010176d:	85 c9                	test   %ecx,%ecx
f010176f:	74 13                	je     f0101784 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101771:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101777:	75 05                	jne    f010177e <memset+0x1d>
f0101779:	f6 c1 03             	test   $0x3,%cl
f010177c:	74 0d                	je     f010178b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010177e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101781:	fc                   	cld    
f0101782:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101784:	89 f8                	mov    %edi,%eax
f0101786:	5b                   	pop    %ebx
f0101787:	5e                   	pop    %esi
f0101788:	5f                   	pop    %edi
f0101789:	5d                   	pop    %ebp
f010178a:	c3                   	ret    
		c &= 0xFF;
f010178b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010178f:	89 d3                	mov    %edx,%ebx
f0101791:	c1 e3 08             	shl    $0x8,%ebx
f0101794:	89 d0                	mov    %edx,%eax
f0101796:	c1 e0 18             	shl    $0x18,%eax
f0101799:	89 d6                	mov    %edx,%esi
f010179b:	c1 e6 10             	shl    $0x10,%esi
f010179e:	09 f0                	or     %esi,%eax
f01017a0:	09 c2                	or     %eax,%edx
f01017a2:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f01017a4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01017a7:	89 d0                	mov    %edx,%eax
f01017a9:	fc                   	cld    
f01017aa:	f3 ab                	rep stos %eax,%es:(%edi)
f01017ac:	eb d6                	jmp    f0101784 <memset+0x23>

f01017ae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01017ae:	55                   	push   %ebp
f01017af:	89 e5                	mov    %esp,%ebp
f01017b1:	57                   	push   %edi
f01017b2:	56                   	push   %esi
f01017b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01017b6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01017bc:	39 c6                	cmp    %eax,%esi
f01017be:	73 35                	jae    f01017f5 <memmove+0x47>
f01017c0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01017c3:	39 c2                	cmp    %eax,%edx
f01017c5:	76 2e                	jbe    f01017f5 <memmove+0x47>
		s += n;
		d += n;
f01017c7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017ca:	89 d6                	mov    %edx,%esi
f01017cc:	09 fe                	or     %edi,%esi
f01017ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01017d4:	74 0c                	je     f01017e2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01017d6:	83 ef 01             	sub    $0x1,%edi
f01017d9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01017dc:	fd                   	std    
f01017dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01017df:	fc                   	cld    
f01017e0:	eb 21                	jmp    f0101803 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017e2:	f6 c1 03             	test   $0x3,%cl
f01017e5:	75 ef                	jne    f01017d6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01017e7:	83 ef 04             	sub    $0x4,%edi
f01017ea:	8d 72 fc             	lea    -0x4(%edx),%esi
f01017ed:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01017f0:	fd                   	std    
f01017f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017f3:	eb ea                	jmp    f01017df <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017f5:	89 f2                	mov    %esi,%edx
f01017f7:	09 c2                	or     %eax,%edx
f01017f9:	f6 c2 03             	test   $0x3,%dl
f01017fc:	74 09                	je     f0101807 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01017fe:	89 c7                	mov    %eax,%edi
f0101800:	fc                   	cld    
f0101801:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101803:	5e                   	pop    %esi
f0101804:	5f                   	pop    %edi
f0101805:	5d                   	pop    %ebp
f0101806:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101807:	f6 c1 03             	test   $0x3,%cl
f010180a:	75 f2                	jne    f01017fe <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010180c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010180f:	89 c7                	mov    %eax,%edi
f0101811:	fc                   	cld    
f0101812:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101814:	eb ed                	jmp    f0101803 <memmove+0x55>

f0101816 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101816:	55                   	push   %ebp
f0101817:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101819:	ff 75 10             	pushl  0x10(%ebp)
f010181c:	ff 75 0c             	pushl  0xc(%ebp)
f010181f:	ff 75 08             	pushl  0x8(%ebp)
f0101822:	e8 87 ff ff ff       	call   f01017ae <memmove>
}
f0101827:	c9                   	leave  
f0101828:	c3                   	ret    

f0101829 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101829:	55                   	push   %ebp
f010182a:	89 e5                	mov    %esp,%ebp
f010182c:	56                   	push   %esi
f010182d:	53                   	push   %ebx
f010182e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101831:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101834:	89 c6                	mov    %eax,%esi
f0101836:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101839:	39 f0                	cmp    %esi,%eax
f010183b:	74 1c                	je     f0101859 <memcmp+0x30>
		if (*s1 != *s2)
f010183d:	0f b6 08             	movzbl (%eax),%ecx
f0101840:	0f b6 1a             	movzbl (%edx),%ebx
f0101843:	38 d9                	cmp    %bl,%cl
f0101845:	75 08                	jne    f010184f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101847:	83 c0 01             	add    $0x1,%eax
f010184a:	83 c2 01             	add    $0x1,%edx
f010184d:	eb ea                	jmp    f0101839 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010184f:	0f b6 c1             	movzbl %cl,%eax
f0101852:	0f b6 db             	movzbl %bl,%ebx
f0101855:	29 d8                	sub    %ebx,%eax
f0101857:	eb 05                	jmp    f010185e <memcmp+0x35>
	}

	return 0;
f0101859:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010185e:	5b                   	pop    %ebx
f010185f:	5e                   	pop    %esi
f0101860:	5d                   	pop    %ebp
f0101861:	c3                   	ret    

f0101862 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101862:	55                   	push   %ebp
f0101863:	89 e5                	mov    %esp,%ebp
f0101865:	8b 45 08             	mov    0x8(%ebp),%eax
f0101868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010186b:	89 c2                	mov    %eax,%edx
f010186d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101870:	39 d0                	cmp    %edx,%eax
f0101872:	73 09                	jae    f010187d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101874:	38 08                	cmp    %cl,(%eax)
f0101876:	74 05                	je     f010187d <memfind+0x1b>
	for (; s < ends; s++)
f0101878:	83 c0 01             	add    $0x1,%eax
f010187b:	eb f3                	jmp    f0101870 <memfind+0xe>
			break;
	return (void *) s;
}
f010187d:	5d                   	pop    %ebp
f010187e:	c3                   	ret    

f010187f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010187f:	55                   	push   %ebp
f0101880:	89 e5                	mov    %esp,%ebp
f0101882:	57                   	push   %edi
f0101883:	56                   	push   %esi
f0101884:	53                   	push   %ebx
f0101885:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101888:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010188b:	eb 03                	jmp    f0101890 <strtol+0x11>
		s++;
f010188d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101890:	0f b6 01             	movzbl (%ecx),%eax
f0101893:	3c 20                	cmp    $0x20,%al
f0101895:	74 f6                	je     f010188d <strtol+0xe>
f0101897:	3c 09                	cmp    $0x9,%al
f0101899:	74 f2                	je     f010188d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010189b:	3c 2b                	cmp    $0x2b,%al
f010189d:	74 2e                	je     f01018cd <strtol+0x4e>
	int neg = 0;
f010189f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01018a4:	3c 2d                	cmp    $0x2d,%al
f01018a6:	74 2f                	je     f01018d7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018a8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01018ae:	75 05                	jne    f01018b5 <strtol+0x36>
f01018b0:	80 39 30             	cmpb   $0x30,(%ecx)
f01018b3:	74 2c                	je     f01018e1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01018b5:	85 db                	test   %ebx,%ebx
f01018b7:	75 0a                	jne    f01018c3 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01018b9:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01018be:	80 39 30             	cmpb   $0x30,(%ecx)
f01018c1:	74 28                	je     f01018eb <strtol+0x6c>
		base = 10;
f01018c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01018c8:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01018cb:	eb 50                	jmp    f010191d <strtol+0x9e>
		s++;
f01018cd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01018d0:	bf 00 00 00 00       	mov    $0x0,%edi
f01018d5:	eb d1                	jmp    f01018a8 <strtol+0x29>
		s++, neg = 1;
f01018d7:	83 c1 01             	add    $0x1,%ecx
f01018da:	bf 01 00 00 00       	mov    $0x1,%edi
f01018df:	eb c7                	jmp    f01018a8 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018e1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01018e5:	74 0e                	je     f01018f5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01018e7:	85 db                	test   %ebx,%ebx
f01018e9:	75 d8                	jne    f01018c3 <strtol+0x44>
		s++, base = 8;
f01018eb:	83 c1 01             	add    $0x1,%ecx
f01018ee:	bb 08 00 00 00       	mov    $0x8,%ebx
f01018f3:	eb ce                	jmp    f01018c3 <strtol+0x44>
		s += 2, base = 16;
f01018f5:	83 c1 02             	add    $0x2,%ecx
f01018f8:	bb 10 00 00 00       	mov    $0x10,%ebx
f01018fd:	eb c4                	jmp    f01018c3 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01018ff:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101902:	89 f3                	mov    %esi,%ebx
f0101904:	80 fb 19             	cmp    $0x19,%bl
f0101907:	77 29                	ja     f0101932 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0101909:	0f be d2             	movsbl %dl,%edx
f010190c:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010190f:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101912:	7d 30                	jge    f0101944 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0101914:	83 c1 01             	add    $0x1,%ecx
f0101917:	0f af 45 10          	imul   0x10(%ebp),%eax
f010191b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010191d:	0f b6 11             	movzbl (%ecx),%edx
f0101920:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101923:	89 f3                	mov    %esi,%ebx
f0101925:	80 fb 09             	cmp    $0x9,%bl
f0101928:	77 d5                	ja     f01018ff <strtol+0x80>
			dig = *s - '0';
f010192a:	0f be d2             	movsbl %dl,%edx
f010192d:	83 ea 30             	sub    $0x30,%edx
f0101930:	eb dd                	jmp    f010190f <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0101932:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101935:	89 f3                	mov    %esi,%ebx
f0101937:	80 fb 19             	cmp    $0x19,%bl
f010193a:	77 08                	ja     f0101944 <strtol+0xc5>
			dig = *s - 'A' + 10;
f010193c:	0f be d2             	movsbl %dl,%edx
f010193f:	83 ea 37             	sub    $0x37,%edx
f0101942:	eb cb                	jmp    f010190f <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101944:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101948:	74 05                	je     f010194f <strtol+0xd0>
		*endptr = (char *) s;
f010194a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010194d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010194f:	89 c2                	mov    %eax,%edx
f0101951:	f7 da                	neg    %edx
f0101953:	85 ff                	test   %edi,%edi
f0101955:	0f 45 c2             	cmovne %edx,%eax
}
f0101958:	5b                   	pop    %ebx
f0101959:	5e                   	pop    %esi
f010195a:	5f                   	pop    %edi
f010195b:	5d                   	pop    %ebp
f010195c:	c3                   	ret    
f010195d:	66 90                	xchg   %ax,%ax
f010195f:	90                   	nop

f0101960 <__udivdi3>:
f0101960:	55                   	push   %ebp
f0101961:	57                   	push   %edi
f0101962:	56                   	push   %esi
f0101963:	53                   	push   %ebx
f0101964:	83 ec 1c             	sub    $0x1c,%esp
f0101967:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010196b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010196f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101973:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101977:	85 d2                	test   %edx,%edx
f0101979:	75 35                	jne    f01019b0 <__udivdi3+0x50>
f010197b:	39 f3                	cmp    %esi,%ebx
f010197d:	0f 87 bd 00 00 00    	ja     f0101a40 <__udivdi3+0xe0>
f0101983:	85 db                	test   %ebx,%ebx
f0101985:	89 d9                	mov    %ebx,%ecx
f0101987:	75 0b                	jne    f0101994 <__udivdi3+0x34>
f0101989:	b8 01 00 00 00       	mov    $0x1,%eax
f010198e:	31 d2                	xor    %edx,%edx
f0101990:	f7 f3                	div    %ebx
f0101992:	89 c1                	mov    %eax,%ecx
f0101994:	31 d2                	xor    %edx,%edx
f0101996:	89 f0                	mov    %esi,%eax
f0101998:	f7 f1                	div    %ecx
f010199a:	89 c6                	mov    %eax,%esi
f010199c:	89 e8                	mov    %ebp,%eax
f010199e:	89 f7                	mov    %esi,%edi
f01019a0:	f7 f1                	div    %ecx
f01019a2:	89 fa                	mov    %edi,%edx
f01019a4:	83 c4 1c             	add    $0x1c,%esp
f01019a7:	5b                   	pop    %ebx
f01019a8:	5e                   	pop    %esi
f01019a9:	5f                   	pop    %edi
f01019aa:	5d                   	pop    %ebp
f01019ab:	c3                   	ret    
f01019ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019b0:	39 f2                	cmp    %esi,%edx
f01019b2:	77 7c                	ja     f0101a30 <__udivdi3+0xd0>
f01019b4:	0f bd fa             	bsr    %edx,%edi
f01019b7:	83 f7 1f             	xor    $0x1f,%edi
f01019ba:	0f 84 98 00 00 00    	je     f0101a58 <__udivdi3+0xf8>
f01019c0:	89 f9                	mov    %edi,%ecx
f01019c2:	b8 20 00 00 00       	mov    $0x20,%eax
f01019c7:	29 f8                	sub    %edi,%eax
f01019c9:	d3 e2                	shl    %cl,%edx
f01019cb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01019cf:	89 c1                	mov    %eax,%ecx
f01019d1:	89 da                	mov    %ebx,%edx
f01019d3:	d3 ea                	shr    %cl,%edx
f01019d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01019d9:	09 d1                	or     %edx,%ecx
f01019db:	89 f2                	mov    %esi,%edx
f01019dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01019e1:	89 f9                	mov    %edi,%ecx
f01019e3:	d3 e3                	shl    %cl,%ebx
f01019e5:	89 c1                	mov    %eax,%ecx
f01019e7:	d3 ea                	shr    %cl,%edx
f01019e9:	89 f9                	mov    %edi,%ecx
f01019eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01019ef:	d3 e6                	shl    %cl,%esi
f01019f1:	89 eb                	mov    %ebp,%ebx
f01019f3:	89 c1                	mov    %eax,%ecx
f01019f5:	d3 eb                	shr    %cl,%ebx
f01019f7:	09 de                	or     %ebx,%esi
f01019f9:	89 f0                	mov    %esi,%eax
f01019fb:	f7 74 24 08          	divl   0x8(%esp)
f01019ff:	89 d6                	mov    %edx,%esi
f0101a01:	89 c3                	mov    %eax,%ebx
f0101a03:	f7 64 24 0c          	mull   0xc(%esp)
f0101a07:	39 d6                	cmp    %edx,%esi
f0101a09:	72 0c                	jb     f0101a17 <__udivdi3+0xb7>
f0101a0b:	89 f9                	mov    %edi,%ecx
f0101a0d:	d3 e5                	shl    %cl,%ebp
f0101a0f:	39 c5                	cmp    %eax,%ebp
f0101a11:	73 5d                	jae    f0101a70 <__udivdi3+0x110>
f0101a13:	39 d6                	cmp    %edx,%esi
f0101a15:	75 59                	jne    f0101a70 <__udivdi3+0x110>
f0101a17:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101a1a:	31 ff                	xor    %edi,%edi
f0101a1c:	89 fa                	mov    %edi,%edx
f0101a1e:	83 c4 1c             	add    $0x1c,%esp
f0101a21:	5b                   	pop    %ebx
f0101a22:	5e                   	pop    %esi
f0101a23:	5f                   	pop    %edi
f0101a24:	5d                   	pop    %ebp
f0101a25:	c3                   	ret    
f0101a26:	8d 76 00             	lea    0x0(%esi),%esi
f0101a29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101a30:	31 ff                	xor    %edi,%edi
f0101a32:	31 c0                	xor    %eax,%eax
f0101a34:	89 fa                	mov    %edi,%edx
f0101a36:	83 c4 1c             	add    $0x1c,%esp
f0101a39:	5b                   	pop    %ebx
f0101a3a:	5e                   	pop    %esi
f0101a3b:	5f                   	pop    %edi
f0101a3c:	5d                   	pop    %ebp
f0101a3d:	c3                   	ret    
f0101a3e:	66 90                	xchg   %ax,%ax
f0101a40:	31 ff                	xor    %edi,%edi
f0101a42:	89 e8                	mov    %ebp,%eax
f0101a44:	89 f2                	mov    %esi,%edx
f0101a46:	f7 f3                	div    %ebx
f0101a48:	89 fa                	mov    %edi,%edx
f0101a4a:	83 c4 1c             	add    $0x1c,%esp
f0101a4d:	5b                   	pop    %ebx
f0101a4e:	5e                   	pop    %esi
f0101a4f:	5f                   	pop    %edi
f0101a50:	5d                   	pop    %ebp
f0101a51:	c3                   	ret    
f0101a52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a58:	39 f2                	cmp    %esi,%edx
f0101a5a:	72 06                	jb     f0101a62 <__udivdi3+0x102>
f0101a5c:	31 c0                	xor    %eax,%eax
f0101a5e:	39 eb                	cmp    %ebp,%ebx
f0101a60:	77 d2                	ja     f0101a34 <__udivdi3+0xd4>
f0101a62:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a67:	eb cb                	jmp    f0101a34 <__udivdi3+0xd4>
f0101a69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a70:	89 d8                	mov    %ebx,%eax
f0101a72:	31 ff                	xor    %edi,%edi
f0101a74:	eb be                	jmp    f0101a34 <__udivdi3+0xd4>
f0101a76:	66 90                	xchg   %ax,%ax
f0101a78:	66 90                	xchg   %ax,%ax
f0101a7a:	66 90                	xchg   %ax,%ax
f0101a7c:	66 90                	xchg   %ax,%ax
f0101a7e:	66 90                	xchg   %ax,%ax

f0101a80 <__umoddi3>:
f0101a80:	55                   	push   %ebp
f0101a81:	57                   	push   %edi
f0101a82:	56                   	push   %esi
f0101a83:	53                   	push   %ebx
f0101a84:	83 ec 1c             	sub    $0x1c,%esp
f0101a87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101a8b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101a8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a93:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101a97:	85 ed                	test   %ebp,%ebp
f0101a99:	89 f0                	mov    %esi,%eax
f0101a9b:	89 da                	mov    %ebx,%edx
f0101a9d:	75 19                	jne    f0101ab8 <__umoddi3+0x38>
f0101a9f:	39 df                	cmp    %ebx,%edi
f0101aa1:	0f 86 b1 00 00 00    	jbe    f0101b58 <__umoddi3+0xd8>
f0101aa7:	f7 f7                	div    %edi
f0101aa9:	89 d0                	mov    %edx,%eax
f0101aab:	31 d2                	xor    %edx,%edx
f0101aad:	83 c4 1c             	add    $0x1c,%esp
f0101ab0:	5b                   	pop    %ebx
f0101ab1:	5e                   	pop    %esi
f0101ab2:	5f                   	pop    %edi
f0101ab3:	5d                   	pop    %ebp
f0101ab4:	c3                   	ret    
f0101ab5:	8d 76 00             	lea    0x0(%esi),%esi
f0101ab8:	39 dd                	cmp    %ebx,%ebp
f0101aba:	77 f1                	ja     f0101aad <__umoddi3+0x2d>
f0101abc:	0f bd cd             	bsr    %ebp,%ecx
f0101abf:	83 f1 1f             	xor    $0x1f,%ecx
f0101ac2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101ac6:	0f 84 b4 00 00 00    	je     f0101b80 <__umoddi3+0x100>
f0101acc:	b8 20 00 00 00       	mov    $0x20,%eax
f0101ad1:	89 c2                	mov    %eax,%edx
f0101ad3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101ad7:	29 c2                	sub    %eax,%edx
f0101ad9:	89 c1                	mov    %eax,%ecx
f0101adb:	89 f8                	mov    %edi,%eax
f0101add:	d3 e5                	shl    %cl,%ebp
f0101adf:	89 d1                	mov    %edx,%ecx
f0101ae1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101ae5:	d3 e8                	shr    %cl,%eax
f0101ae7:	09 c5                	or     %eax,%ebp
f0101ae9:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101aed:	89 c1                	mov    %eax,%ecx
f0101aef:	d3 e7                	shl    %cl,%edi
f0101af1:	89 d1                	mov    %edx,%ecx
f0101af3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101af7:	89 df                	mov    %ebx,%edi
f0101af9:	d3 ef                	shr    %cl,%edi
f0101afb:	89 c1                	mov    %eax,%ecx
f0101afd:	89 f0                	mov    %esi,%eax
f0101aff:	d3 e3                	shl    %cl,%ebx
f0101b01:	89 d1                	mov    %edx,%ecx
f0101b03:	89 fa                	mov    %edi,%edx
f0101b05:	d3 e8                	shr    %cl,%eax
f0101b07:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101b0c:	09 d8                	or     %ebx,%eax
f0101b0e:	f7 f5                	div    %ebp
f0101b10:	d3 e6                	shl    %cl,%esi
f0101b12:	89 d1                	mov    %edx,%ecx
f0101b14:	f7 64 24 08          	mull   0x8(%esp)
f0101b18:	39 d1                	cmp    %edx,%ecx
f0101b1a:	89 c3                	mov    %eax,%ebx
f0101b1c:	89 d7                	mov    %edx,%edi
f0101b1e:	72 06                	jb     f0101b26 <__umoddi3+0xa6>
f0101b20:	75 0e                	jne    f0101b30 <__umoddi3+0xb0>
f0101b22:	39 c6                	cmp    %eax,%esi
f0101b24:	73 0a                	jae    f0101b30 <__umoddi3+0xb0>
f0101b26:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101b2a:	19 ea                	sbb    %ebp,%edx
f0101b2c:	89 d7                	mov    %edx,%edi
f0101b2e:	89 c3                	mov    %eax,%ebx
f0101b30:	89 ca                	mov    %ecx,%edx
f0101b32:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101b37:	29 de                	sub    %ebx,%esi
f0101b39:	19 fa                	sbb    %edi,%edx
f0101b3b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0101b3f:	89 d0                	mov    %edx,%eax
f0101b41:	d3 e0                	shl    %cl,%eax
f0101b43:	89 d9                	mov    %ebx,%ecx
f0101b45:	d3 ee                	shr    %cl,%esi
f0101b47:	d3 ea                	shr    %cl,%edx
f0101b49:	09 f0                	or     %esi,%eax
f0101b4b:	83 c4 1c             	add    $0x1c,%esp
f0101b4e:	5b                   	pop    %ebx
f0101b4f:	5e                   	pop    %esi
f0101b50:	5f                   	pop    %edi
f0101b51:	5d                   	pop    %ebp
f0101b52:	c3                   	ret    
f0101b53:	90                   	nop
f0101b54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b58:	85 ff                	test   %edi,%edi
f0101b5a:	89 f9                	mov    %edi,%ecx
f0101b5c:	75 0b                	jne    f0101b69 <__umoddi3+0xe9>
f0101b5e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b63:	31 d2                	xor    %edx,%edx
f0101b65:	f7 f7                	div    %edi
f0101b67:	89 c1                	mov    %eax,%ecx
f0101b69:	89 d8                	mov    %ebx,%eax
f0101b6b:	31 d2                	xor    %edx,%edx
f0101b6d:	f7 f1                	div    %ecx
f0101b6f:	89 f0                	mov    %esi,%eax
f0101b71:	f7 f1                	div    %ecx
f0101b73:	e9 31 ff ff ff       	jmp    f0101aa9 <__umoddi3+0x29>
f0101b78:	90                   	nop
f0101b79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b80:	39 dd                	cmp    %ebx,%ebp
f0101b82:	72 08                	jb     f0101b8c <__umoddi3+0x10c>
f0101b84:	39 f7                	cmp    %esi,%edi
f0101b86:	0f 87 21 ff ff ff    	ja     f0101aad <__umoddi3+0x2d>
f0101b8c:	89 da                	mov    %ebx,%edx
f0101b8e:	89 f0                	mov    %esi,%eax
f0101b90:	29 f8                	sub    %edi,%eax
f0101b92:	19 ea                	sbb    %ebp,%edx
f0101b94:	e9 14 ff ff ff       	jmp    f0101aad <__umoddi3+0x2d>
