
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 03 01 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f010004c:	81 c3 bc 72 01 00    	add    $0x172bc,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c2 60 90 11 f0    	mov    $0xf0119060,%edx
f0100058:	c7 c0 c0 96 11 f0    	mov    $0xf01196c0,%eax
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 3c 3b 00 00       	call   f0103ba5 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 36 05 00 00       	call   f01005a4 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 f8 cc fe ff    	lea    -0x13308(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 c7 2f 00 00       	call   f0103049 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 d1 12 00 00       	call   f0101358 <mem_init>
f0100087:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010008a:	83 ec 0c             	sub    $0xc,%esp
f010008d:	6a 00                	push   $0x0
f010008f:	e8 8c 07 00 00       	call   f0100820 <monitor>
f0100094:	83 c4 10             	add    $0x10,%esp
f0100097:	eb f1                	jmp    f010008a <i386_init+0x4a>

f0100099 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100099:	55                   	push   %ebp
f010009a:	89 e5                	mov    %esp,%ebp
f010009c:	57                   	push   %edi
f010009d:	56                   	push   %esi
f010009e:	53                   	push   %ebx
f010009f:	83 ec 0c             	sub    $0xc,%esp
f01000a2:	e8 a8 00 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f01000a7:	81 c3 61 72 01 00    	add    $0x17261,%ebx
f01000ad:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f01000b0:	c7 c0 c4 96 11 f0    	mov    $0xf01196c4,%eax
f01000b6:	83 38 00             	cmpl   $0x0,(%eax)
f01000b9:	74 0f                	je     f01000ca <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000bb:	83 ec 0c             	sub    $0xc,%esp
f01000be:	6a 00                	push   $0x0
f01000c0:	e8 5b 07 00 00       	call   f0100820 <monitor>
f01000c5:	83 c4 10             	add    $0x10,%esp
f01000c8:	eb f1                	jmp    f01000bb <_panic+0x22>
	panicstr = fmt;
f01000ca:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f01000cc:	fa                   	cli    
f01000cd:	fc                   	cld    
	va_start(ap, fmt);
f01000ce:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d1:	83 ec 04             	sub    $0x4,%esp
f01000d4:	ff 75 0c             	pushl  0xc(%ebp)
f01000d7:	ff 75 08             	pushl  0x8(%ebp)
f01000da:	8d 83 13 cd fe ff    	lea    -0x132ed(%ebx),%eax
f01000e0:	50                   	push   %eax
f01000e1:	e8 63 2f 00 00       	call   f0103049 <cprintf>
	vcprintf(fmt, ap);
f01000e6:	83 c4 08             	add    $0x8,%esp
f01000e9:	56                   	push   %esi
f01000ea:	57                   	push   %edi
f01000eb:	e8 22 2f 00 00       	call   f0103012 <vcprintf>
	cprintf("\n");
f01000f0:	8d 83 82 d4 fe ff    	lea    -0x12b7e(%ebx),%eax
f01000f6:	89 04 24             	mov    %eax,(%esp)
f01000f9:	e8 4b 2f 00 00       	call   f0103049 <cprintf>
f01000fe:	83 c4 10             	add    $0x10,%esp
f0100101:	eb b8                	jmp    f01000bb <_panic+0x22>

f0100103 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100103:	55                   	push   %ebp
f0100104:	89 e5                	mov    %esp,%ebp
f0100106:	56                   	push   %esi
f0100107:	53                   	push   %ebx
f0100108:	e8 42 00 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f010010d:	81 c3 fb 71 01 00    	add    $0x171fb,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100113:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100116:	83 ec 04             	sub    $0x4,%esp
f0100119:	ff 75 0c             	pushl  0xc(%ebp)
f010011c:	ff 75 08             	pushl  0x8(%ebp)
f010011f:	8d 83 2b cd fe ff    	lea    -0x132d5(%ebx),%eax
f0100125:	50                   	push   %eax
f0100126:	e8 1e 2f 00 00       	call   f0103049 <cprintf>
	vcprintf(fmt, ap);
f010012b:	83 c4 08             	add    $0x8,%esp
f010012e:	56                   	push   %esi
f010012f:	ff 75 10             	pushl  0x10(%ebp)
f0100132:	e8 db 2e 00 00       	call   f0103012 <vcprintf>
	cprintf("\n");
f0100137:	8d 83 82 d4 fe ff    	lea    -0x12b7e(%ebx),%eax
f010013d:	89 04 24             	mov    %eax,(%esp)
f0100140:	e8 04 2f 00 00       	call   f0103049 <cprintf>
	va_end(ap);
}
f0100145:	83 c4 10             	add    $0x10,%esp
f0100148:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010014b:	5b                   	pop    %ebx
f010014c:	5e                   	pop    %esi
f010014d:	5d                   	pop    %ebp
f010014e:	c3                   	ret    

f010014f <__x86.get_pc_thunk.bx>:
f010014f:	8b 1c 24             	mov    (%esp),%ebx
f0100152:	c3                   	ret    

f0100153 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100153:	55                   	push   %ebp
f0100154:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100156:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010015b:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010015c:	a8 01                	test   $0x1,%al
f010015e:	74 0b                	je     f010016b <serial_proc_data+0x18>
f0100160:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100165:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100166:	0f b6 c0             	movzbl %al,%eax
}
f0100169:	5d                   	pop    %ebp
f010016a:	c3                   	ret    
		return -1;
f010016b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100170:	eb f7                	jmp    f0100169 <serial_proc_data+0x16>

f0100172 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100172:	55                   	push   %ebp
f0100173:	89 e5                	mov    %esp,%ebp
f0100175:	56                   	push   %esi
f0100176:	53                   	push   %ebx
f0100177:	e8 d3 ff ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010017c:	81 c3 8c 71 01 00    	add    $0x1718c,%ebx
f0100182:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f0100184:	ff d6                	call   *%esi
f0100186:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100189:	74 2e                	je     f01001b9 <cons_intr+0x47>
		if (c == 0)
f010018b:	85 c0                	test   %eax,%eax
f010018d:	74 f5                	je     f0100184 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f010018f:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100195:	8d 51 01             	lea    0x1(%ecx),%edx
f0100198:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010019e:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001a5:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001ab:	75 d7                	jne    f0100184 <cons_intr+0x12>
			cons.wpos = 0;
f01001ad:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f01001b4:	00 00 00 
f01001b7:	eb cb                	jmp    f0100184 <cons_intr+0x12>
	}
}
f01001b9:	5b                   	pop    %ebx
f01001ba:	5e                   	pop    %esi
f01001bb:	5d                   	pop    %ebp
f01001bc:	c3                   	ret    

f01001bd <kbd_proc_data>:
{
f01001bd:	55                   	push   %ebp
f01001be:	89 e5                	mov    %esp,%ebp
f01001c0:	56                   	push   %esi
f01001c1:	53                   	push   %ebx
f01001c2:	e8 88 ff ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01001c7:	81 c3 41 71 01 00    	add    $0x17141,%ebx
f01001cd:	ba 64 00 00 00       	mov    $0x64,%edx
f01001d2:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001d3:	a8 01                	test   $0x1,%al
f01001d5:	0f 84 06 01 00 00    	je     f01002e1 <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f01001db:	a8 20                	test   $0x20,%al
f01001dd:	0f 85 05 01 00 00    	jne    f01002e8 <kbd_proc_data+0x12b>
f01001e3:	ba 60 00 00 00       	mov    $0x60,%edx
f01001e8:	ec                   	in     (%dx),%al
f01001e9:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01001eb:	3c e0                	cmp    $0xe0,%al
f01001ed:	0f 84 93 00 00 00    	je     f0100286 <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f01001f3:	84 c0                	test   %al,%al
f01001f5:	0f 88 a0 00 00 00    	js     f010029b <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f01001fb:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100201:	f6 c1 40             	test   $0x40,%cl
f0100204:	74 0e                	je     f0100214 <kbd_proc_data+0x57>
		data |= 0x80;
f0100206:	83 c8 80             	or     $0xffffff80,%eax
f0100209:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010020b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010020e:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100214:	0f b6 d2             	movzbl %dl,%edx
f0100217:	0f b6 84 13 78 ce fe 	movzbl -0x13188(%ebx,%edx,1),%eax
f010021e:	ff 
f010021f:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100225:	0f b6 8c 13 78 cd fe 	movzbl -0x13288(%ebx,%edx,1),%ecx
f010022c:	ff 
f010022d:	31 c8                	xor    %ecx,%eax
f010022f:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100235:	89 c1                	mov    %eax,%ecx
f0100237:	83 e1 03             	and    $0x3,%ecx
f010023a:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f0100241:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100245:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f0100248:	a8 08                	test   $0x8,%al
f010024a:	74 0d                	je     f0100259 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f010024c:	89 f2                	mov    %esi,%edx
f010024e:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100251:	83 f9 19             	cmp    $0x19,%ecx
f0100254:	77 7a                	ja     f01002d0 <kbd_proc_data+0x113>
			c += 'A' - 'a';
f0100256:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100259:	f7 d0                	not    %eax
f010025b:	a8 06                	test   $0x6,%al
f010025d:	75 33                	jne    f0100292 <kbd_proc_data+0xd5>
f010025f:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100265:	75 2b                	jne    f0100292 <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f0100267:	83 ec 0c             	sub    $0xc,%esp
f010026a:	8d 83 45 cd fe ff    	lea    -0x132bb(%ebx),%eax
f0100270:	50                   	push   %eax
f0100271:	e8 d3 2d 00 00       	call   f0103049 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100276:	b8 03 00 00 00       	mov    $0x3,%eax
f010027b:	ba 92 00 00 00       	mov    $0x92,%edx
f0100280:	ee                   	out    %al,(%dx)
f0100281:	83 c4 10             	add    $0x10,%esp
f0100284:	eb 0c                	jmp    f0100292 <kbd_proc_data+0xd5>
		shift |= E0ESC;
f0100286:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f010028d:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100292:	89 f0                	mov    %esi,%eax
f0100294:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100297:	5b                   	pop    %ebx
f0100298:	5e                   	pop    %esi
f0100299:	5d                   	pop    %ebp
f010029a:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010029b:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f01002a1:	89 ce                	mov    %ecx,%esi
f01002a3:	83 e6 40             	and    $0x40,%esi
f01002a6:	83 e0 7f             	and    $0x7f,%eax
f01002a9:	85 f6                	test   %esi,%esi
f01002ab:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002ae:	0f b6 d2             	movzbl %dl,%edx
f01002b1:	0f b6 84 13 78 ce fe 	movzbl -0x13188(%ebx,%edx,1),%eax
f01002b8:	ff 
f01002b9:	83 c8 40             	or     $0x40,%eax
f01002bc:	0f b6 c0             	movzbl %al,%eax
f01002bf:	f7 d0                	not    %eax
f01002c1:	21 c8                	and    %ecx,%eax
f01002c3:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f01002c9:	be 00 00 00 00       	mov    $0x0,%esi
f01002ce:	eb c2                	jmp    f0100292 <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f01002d0:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002d3:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002d6:	83 fa 1a             	cmp    $0x1a,%edx
f01002d9:	0f 42 f1             	cmovb  %ecx,%esi
f01002dc:	e9 78 ff ff ff       	jmp    f0100259 <kbd_proc_data+0x9c>
		return -1;
f01002e1:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002e6:	eb aa                	jmp    f0100292 <kbd_proc_data+0xd5>
		return -1;
f01002e8:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002ed:	eb a3                	jmp    f0100292 <kbd_proc_data+0xd5>

f01002ef <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002ef:	55                   	push   %ebp
f01002f0:	89 e5                	mov    %esp,%ebp
f01002f2:	57                   	push   %edi
f01002f3:	56                   	push   %esi
f01002f4:	53                   	push   %ebx
f01002f5:	83 ec 1c             	sub    $0x1c,%esp
f01002f8:	e8 52 fe ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01002fd:	81 c3 0b 70 01 00    	add    $0x1700b,%ebx
f0100303:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100306:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010030b:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100310:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100315:	eb 09                	jmp    f0100320 <cons_putc+0x31>
f0100317:	89 ca                	mov    %ecx,%edx
f0100319:	ec                   	in     (%dx),%al
f010031a:	ec                   	in     (%dx),%al
f010031b:	ec                   	in     (%dx),%al
f010031c:	ec                   	in     (%dx),%al
	     i++)
f010031d:	83 c6 01             	add    $0x1,%esi
f0100320:	89 fa                	mov    %edi,%edx
f0100322:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100323:	a8 20                	test   $0x20,%al
f0100325:	75 08                	jne    f010032f <cons_putc+0x40>
f0100327:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010032d:	7e e8                	jle    f0100317 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010032f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100332:	89 f8                	mov    %edi,%eax
f0100334:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100337:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010033c:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010033d:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100342:	bf 79 03 00 00       	mov    $0x379,%edi
f0100347:	b9 84 00 00 00       	mov    $0x84,%ecx
f010034c:	eb 09                	jmp    f0100357 <cons_putc+0x68>
f010034e:	89 ca                	mov    %ecx,%edx
f0100350:	ec                   	in     (%dx),%al
f0100351:	ec                   	in     (%dx),%al
f0100352:	ec                   	in     (%dx),%al
f0100353:	ec                   	in     (%dx),%al
f0100354:	83 c6 01             	add    $0x1,%esi
f0100357:	89 fa                	mov    %edi,%edx
f0100359:	ec                   	in     (%dx),%al
f010035a:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100360:	7f 04                	jg     f0100366 <cons_putc+0x77>
f0100362:	84 c0                	test   %al,%al
f0100364:	79 e8                	jns    f010034e <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100366:	ba 78 03 00 00       	mov    $0x378,%edx
f010036b:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f010036f:	ee                   	out    %al,(%dx)
f0100370:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100375:	b8 0d 00 00 00       	mov    $0xd,%eax
f010037a:	ee                   	out    %al,(%dx)
f010037b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100380:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100384:	89 fa                	mov    %edi,%edx
f0100386:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010038c:	89 f8                	mov    %edi,%eax
f010038e:	80 cc 07             	or     $0x7,%ah
f0100391:	85 d2                	test   %edx,%edx
f0100393:	0f 45 c7             	cmovne %edi,%eax
f0100396:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100399:	0f b6 c0             	movzbl %al,%eax
f010039c:	83 f8 09             	cmp    $0x9,%eax
f010039f:	0f 84 b9 00 00 00    	je     f010045e <cons_putc+0x16f>
f01003a5:	83 f8 09             	cmp    $0x9,%eax
f01003a8:	7e 74                	jle    f010041e <cons_putc+0x12f>
f01003aa:	83 f8 0a             	cmp    $0xa,%eax
f01003ad:	0f 84 9e 00 00 00    	je     f0100451 <cons_putc+0x162>
f01003b3:	83 f8 0d             	cmp    $0xd,%eax
f01003b6:	0f 85 d9 00 00 00    	jne    f0100495 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f01003bc:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01003c3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003c9:	c1 e8 16             	shr    $0x16,%eax
f01003cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003cf:	c1 e0 04             	shl    $0x4,%eax
f01003d2:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01003d9:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f01003e0:	cf 07 
f01003e2:	0f 87 d4 00 00 00    	ja     f01004bc <cons_putc+0x1cd>
	outb(addr_6845, 14);
f01003e8:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f01003ee:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003f3:	89 ca                	mov    %ecx,%edx
f01003f5:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003f6:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f01003fd:	8d 71 01             	lea    0x1(%ecx),%esi
f0100400:	89 d8                	mov    %ebx,%eax
f0100402:	66 c1 e8 08          	shr    $0x8,%ax
f0100406:	89 f2                	mov    %esi,%edx
f0100408:	ee                   	out    %al,(%dx)
f0100409:	b8 0f 00 00 00       	mov    $0xf,%eax
f010040e:	89 ca                	mov    %ecx,%edx
f0100410:	ee                   	out    %al,(%dx)
f0100411:	89 d8                	mov    %ebx,%eax
f0100413:	89 f2                	mov    %esi,%edx
f0100415:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100416:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100419:	5b                   	pop    %ebx
f010041a:	5e                   	pop    %esi
f010041b:	5f                   	pop    %edi
f010041c:	5d                   	pop    %ebp
f010041d:	c3                   	ret    
	switch (c & 0xff) {
f010041e:	83 f8 08             	cmp    $0x8,%eax
f0100421:	75 72                	jne    f0100495 <cons_putc+0x1a6>
		if (crt_pos > 0) {
f0100423:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010042a:	66 85 c0             	test   %ax,%ax
f010042d:	74 b9                	je     f01003e8 <cons_putc+0xf9>
			crt_pos--;
f010042f:	83 e8 01             	sub    $0x1,%eax
f0100432:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100439:	0f b7 c0             	movzwl %ax,%eax
f010043c:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100440:	b2 00                	mov    $0x0,%dl
f0100442:	83 ca 20             	or     $0x20,%edx
f0100445:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f010044b:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f010044f:	eb 88                	jmp    f01003d9 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f0100451:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f0100458:	50 
f0100459:	e9 5e ff ff ff       	jmp    f01003bc <cons_putc+0xcd>
		cons_putc(' ');
f010045e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100463:	e8 87 fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f0100468:	b8 20 00 00 00       	mov    $0x20,%eax
f010046d:	e8 7d fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f0100472:	b8 20 00 00 00       	mov    $0x20,%eax
f0100477:	e8 73 fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f010047c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100481:	e8 69 fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f0100486:	b8 20 00 00 00       	mov    $0x20,%eax
f010048b:	e8 5f fe ff ff       	call   f01002ef <cons_putc>
f0100490:	e9 44 ff ff ff       	jmp    f01003d9 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100495:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010049c:	8d 50 01             	lea    0x1(%eax),%edx
f010049f:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f01004af:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004b3:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004b7:	e9 1d ff ff ff       	jmp    f01003d9 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004bc:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f01004c2:	83 ec 04             	sub    $0x4,%esp
f01004c5:	68 00 0f 00 00       	push   $0xf00
f01004ca:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004d0:	52                   	push   %edx
f01004d1:	50                   	push   %eax
f01004d2:	e8 1b 37 00 00       	call   f0103bf2 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004d7:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f01004dd:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004e3:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004e9:	83 c4 10             	add    $0x10,%esp
f01004ec:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004f1:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004f4:	39 d0                	cmp    %edx,%eax
f01004f6:	75 f4                	jne    f01004ec <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f01004f8:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f01004ff:	50 
f0100500:	e9 e3 fe ff ff       	jmp    f01003e8 <cons_putc+0xf9>

f0100505 <serial_intr>:
{
f0100505:	e8 e7 01 00 00       	call   f01006f1 <__x86.get_pc_thunk.ax>
f010050a:	05 fe 6d 01 00       	add    $0x16dfe,%eax
	if (serial_exists)
f010050f:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100516:	75 02                	jne    f010051a <serial_intr+0x15>
f0100518:	f3 c3                	repz ret 
{
f010051a:	55                   	push   %ebp
f010051b:	89 e5                	mov    %esp,%ebp
f010051d:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100520:	8d 80 4b 8e fe ff    	lea    -0x171b5(%eax),%eax
f0100526:	e8 47 fc ff ff       	call   f0100172 <cons_intr>
}
f010052b:	c9                   	leave  
f010052c:	c3                   	ret    

f010052d <kbd_intr>:
{
f010052d:	55                   	push   %ebp
f010052e:	89 e5                	mov    %esp,%ebp
f0100530:	83 ec 08             	sub    $0x8,%esp
f0100533:	e8 b9 01 00 00       	call   f01006f1 <__x86.get_pc_thunk.ax>
f0100538:	05 d0 6d 01 00       	add    $0x16dd0,%eax
	cons_intr(kbd_proc_data);
f010053d:	8d 80 b5 8e fe ff    	lea    -0x1714b(%eax),%eax
f0100543:	e8 2a fc ff ff       	call   f0100172 <cons_intr>
}
f0100548:	c9                   	leave  
f0100549:	c3                   	ret    

f010054a <cons_getc>:
{
f010054a:	55                   	push   %ebp
f010054b:	89 e5                	mov    %esp,%ebp
f010054d:	53                   	push   %ebx
f010054e:	83 ec 04             	sub    $0x4,%esp
f0100551:	e8 f9 fb ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100556:	81 c3 b2 6d 01 00    	add    $0x16db2,%ebx
	serial_intr();
f010055c:	e8 a4 ff ff ff       	call   f0100505 <serial_intr>
	kbd_intr();
f0100561:	e8 c7 ff ff ff       	call   f010052d <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100566:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f010056c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100571:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f0100577:	74 19                	je     f0100592 <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f0100579:	8d 4a 01             	lea    0x1(%edx),%ecx
f010057c:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f0100582:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f0100589:	00 
		if (cons.rpos == CONSBUFSIZE)
f010058a:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100590:	74 06                	je     f0100598 <cons_getc+0x4e>
}
f0100592:	83 c4 04             	add    $0x4,%esp
f0100595:	5b                   	pop    %ebx
f0100596:	5d                   	pop    %ebp
f0100597:	c3                   	ret    
			cons.rpos = 0;
f0100598:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010059f:	00 00 00 
f01005a2:	eb ee                	jmp    f0100592 <cons_getc+0x48>

f01005a4 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005a4:	55                   	push   %ebp
f01005a5:	89 e5                	mov    %esp,%ebp
f01005a7:	57                   	push   %edi
f01005a8:	56                   	push   %esi
f01005a9:	53                   	push   %ebx
f01005aa:	83 ec 1c             	sub    $0x1c,%esp
f01005ad:	e8 9d fb ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01005b2:	81 c3 56 6d 01 00    	add    $0x16d56,%ebx
	was = *cp;
f01005b8:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005bf:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005c6:	5a a5 
	if (*cp != 0xA55A) {
f01005c8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005cf:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005d3:	0f 84 bc 00 00 00    	je     f0100695 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f01005d9:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f01005e0:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005e3:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f01005ea:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f01005f0:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005f5:	89 fa                	mov    %edi,%edx
f01005f7:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005f8:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005fb:	89 ca                	mov    %ecx,%edx
f01005fd:	ec                   	in     (%dx),%al
f01005fe:	0f b6 f0             	movzbl %al,%esi
f0100601:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100604:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100609:	89 fa                	mov    %edi,%edx
f010060b:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060c:	89 ca                	mov    %ecx,%edx
f010060e:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100612:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100618:	0f b6 c0             	movzbl %al,%eax
f010061b:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010061d:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100624:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100629:	89 c8                	mov    %ecx,%eax
f010062b:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100630:	ee                   	out    %al,(%dx)
f0100631:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100636:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010063b:	89 fa                	mov    %edi,%edx
f010063d:	ee                   	out    %al,(%dx)
f010063e:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100643:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100648:	ee                   	out    %al,(%dx)
f0100649:	be f9 03 00 00       	mov    $0x3f9,%esi
f010064e:	89 c8                	mov    %ecx,%eax
f0100650:	89 f2                	mov    %esi,%edx
f0100652:	ee                   	out    %al,(%dx)
f0100653:	b8 03 00 00 00       	mov    $0x3,%eax
f0100658:	89 fa                	mov    %edi,%edx
f010065a:	ee                   	out    %al,(%dx)
f010065b:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100660:	89 c8                	mov    %ecx,%eax
f0100662:	ee                   	out    %al,(%dx)
f0100663:	b8 01 00 00 00       	mov    $0x1,%eax
f0100668:	89 f2                	mov    %esi,%edx
f010066a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010066b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100670:	ec                   	in     (%dx),%al
f0100671:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100673:	3c ff                	cmp    $0xff,%al
f0100675:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f010067c:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100681:	ec                   	in     (%dx),%al
f0100682:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100687:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100688:	80 f9 ff             	cmp    $0xff,%cl
f010068b:	74 25                	je     f01006b2 <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f010068d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100690:	5b                   	pop    %ebx
f0100691:	5e                   	pop    %esi
f0100692:	5f                   	pop    %edi
f0100693:	5d                   	pop    %ebp
f0100694:	c3                   	ret    
		*cp = was;
f0100695:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010069c:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f01006a3:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006a6:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01006ad:	e9 38 ff ff ff       	jmp    f01005ea <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f01006b2:	83 ec 0c             	sub    $0xc,%esp
f01006b5:	8d 83 51 cd fe ff    	lea    -0x132af(%ebx),%eax
f01006bb:	50                   	push   %eax
f01006bc:	e8 88 29 00 00       	call   f0103049 <cprintf>
f01006c1:	83 c4 10             	add    $0x10,%esp
}
f01006c4:	eb c7                	jmp    f010068d <cons_init+0xe9>

f01006c6 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006c6:	55                   	push   %ebp
f01006c7:	89 e5                	mov    %esp,%ebp
f01006c9:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01006cf:	e8 1b fc ff ff       	call   f01002ef <cons_putc>
}
f01006d4:	c9                   	leave  
f01006d5:	c3                   	ret    

f01006d6 <getchar>:

int
getchar(void)
{
f01006d6:	55                   	push   %ebp
f01006d7:	89 e5                	mov    %esp,%ebp
f01006d9:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006dc:	e8 69 fe ff ff       	call   f010054a <cons_getc>
f01006e1:	85 c0                	test   %eax,%eax
f01006e3:	74 f7                	je     f01006dc <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006e5:	c9                   	leave  
f01006e6:	c3                   	ret    

f01006e7 <iscons>:

int
iscons(int fdnum)
{
f01006e7:	55                   	push   %ebp
f01006e8:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01006ef:	5d                   	pop    %ebp
f01006f0:	c3                   	ret    

f01006f1 <__x86.get_pc_thunk.ax>:
f01006f1:	8b 04 24             	mov    (%esp),%eax
f01006f4:	c3                   	ret    

f01006f5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006f5:	55                   	push   %ebp
f01006f6:	89 e5                	mov    %esp,%ebp
f01006f8:	56                   	push   %esi
f01006f9:	53                   	push   %ebx
f01006fa:	e8 50 fa ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01006ff:	81 c3 09 6c 01 00    	add    $0x16c09,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100705:	83 ec 04             	sub    $0x4,%esp
f0100708:	8d 83 78 cf fe ff    	lea    -0x13088(%ebx),%eax
f010070e:	50                   	push   %eax
f010070f:	8d 83 96 cf fe ff    	lea    -0x1306a(%ebx),%eax
f0100715:	50                   	push   %eax
f0100716:	8d b3 9b cf fe ff    	lea    -0x13065(%ebx),%esi
f010071c:	56                   	push   %esi
f010071d:	e8 27 29 00 00       	call   f0103049 <cprintf>
f0100722:	83 c4 0c             	add    $0xc,%esp
f0100725:	8d 83 04 d0 fe ff    	lea    -0x12ffc(%ebx),%eax
f010072b:	50                   	push   %eax
f010072c:	8d 83 a4 cf fe ff    	lea    -0x1305c(%ebx),%eax
f0100732:	50                   	push   %eax
f0100733:	56                   	push   %esi
f0100734:	e8 10 29 00 00       	call   f0103049 <cprintf>
	return 0;
}
f0100739:	b8 00 00 00 00       	mov    $0x0,%eax
f010073e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100741:	5b                   	pop    %ebx
f0100742:	5e                   	pop    %esi
f0100743:	5d                   	pop    %ebp
f0100744:	c3                   	ret    

f0100745 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100745:	55                   	push   %ebp
f0100746:	89 e5                	mov    %esp,%ebp
f0100748:	57                   	push   %edi
f0100749:	56                   	push   %esi
f010074a:	53                   	push   %ebx
f010074b:	83 ec 18             	sub    $0x18,%esp
f010074e:	e8 fc f9 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100753:	81 c3 b5 6b 01 00    	add    $0x16bb5,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100759:	8d 83 ad cf fe ff    	lea    -0x13053(%ebx),%eax
f010075f:	50                   	push   %eax
f0100760:	e8 e4 28 00 00       	call   f0103049 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100765:	83 c4 08             	add    $0x8,%esp
f0100768:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f010076e:	8d 83 2c d0 fe ff    	lea    -0x12fd4(%ebx),%eax
f0100774:	50                   	push   %eax
f0100775:	e8 cf 28 00 00       	call   f0103049 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010077a:	83 c4 0c             	add    $0xc,%esp
f010077d:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100783:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100789:	50                   	push   %eax
f010078a:	57                   	push   %edi
f010078b:	8d 83 54 d0 fe ff    	lea    -0x12fac(%ebx),%eax
f0100791:	50                   	push   %eax
f0100792:	e8 b2 28 00 00       	call   f0103049 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100797:	83 c4 0c             	add    $0xc,%esp
f010079a:	c7 c0 e9 3f 10 f0    	mov    $0xf0103fe9,%eax
f01007a0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007a6:	52                   	push   %edx
f01007a7:	50                   	push   %eax
f01007a8:	8d 83 78 d0 fe ff    	lea    -0x12f88(%ebx),%eax
f01007ae:	50                   	push   %eax
f01007af:	e8 95 28 00 00       	call   f0103049 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007b4:	83 c4 0c             	add    $0xc,%esp
f01007b7:	c7 c0 60 90 11 f0    	mov    $0xf0119060,%eax
f01007bd:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007c3:	52                   	push   %edx
f01007c4:	50                   	push   %eax
f01007c5:	8d 83 9c d0 fe ff    	lea    -0x12f64(%ebx),%eax
f01007cb:	50                   	push   %eax
f01007cc:	e8 78 28 00 00       	call   f0103049 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007d1:	83 c4 0c             	add    $0xc,%esp
f01007d4:	c7 c6 c0 96 11 f0    	mov    $0xf01196c0,%esi
f01007da:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007e0:	50                   	push   %eax
f01007e1:	56                   	push   %esi
f01007e2:	8d 83 c0 d0 fe ff    	lea    -0x12f40(%ebx),%eax
f01007e8:	50                   	push   %eax
f01007e9:	e8 5b 28 00 00       	call   f0103049 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007ee:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01007f1:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f01007f7:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007f9:	c1 fe 0a             	sar    $0xa,%esi
f01007fc:	56                   	push   %esi
f01007fd:	8d 83 e4 d0 fe ff    	lea    -0x12f1c(%ebx),%eax
f0100803:	50                   	push   %eax
f0100804:	e8 40 28 00 00       	call   f0103049 <cprintf>
	return 0;
}
f0100809:	b8 00 00 00 00       	mov    $0x0,%eax
f010080e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100811:	5b                   	pop    %ebx
f0100812:	5e                   	pop    %esi
f0100813:	5f                   	pop    %edi
f0100814:	5d                   	pop    %ebp
f0100815:	c3                   	ret    

f0100816 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100816:	55                   	push   %ebp
f0100817:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100819:	b8 00 00 00 00       	mov    $0x0,%eax
f010081e:	5d                   	pop    %ebp
f010081f:	c3                   	ret    

f0100820 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100820:	55                   	push   %ebp
f0100821:	89 e5                	mov    %esp,%ebp
f0100823:	57                   	push   %edi
f0100824:	56                   	push   %esi
f0100825:	53                   	push   %ebx
f0100826:	83 ec 68             	sub    $0x68,%esp
f0100829:	e8 21 f9 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010082e:	81 c3 da 6a 01 00    	add    $0x16ada,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100834:	8d 83 10 d1 fe ff    	lea    -0x12ef0(%ebx),%eax
f010083a:	50                   	push   %eax
f010083b:	e8 09 28 00 00       	call   f0103049 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100840:	8d 83 34 d1 fe ff    	lea    -0x12ecc(%ebx),%eax
f0100846:	89 04 24             	mov    %eax,(%esp)
f0100849:	e8 fb 27 00 00       	call   f0103049 <cprintf>
f010084e:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100851:	8d bb ca cf fe ff    	lea    -0x13036(%ebx),%edi
f0100857:	eb 4a                	jmp    f01008a3 <monitor+0x83>
f0100859:	83 ec 08             	sub    $0x8,%esp
f010085c:	0f be c0             	movsbl %al,%eax
f010085f:	50                   	push   %eax
f0100860:	57                   	push   %edi
f0100861:	e8 02 33 00 00       	call   f0103b68 <strchr>
f0100866:	83 c4 10             	add    $0x10,%esp
f0100869:	85 c0                	test   %eax,%eax
f010086b:	74 08                	je     f0100875 <monitor+0x55>
			*buf++ = 0;
f010086d:	c6 06 00             	movb   $0x0,(%esi)
f0100870:	8d 76 01             	lea    0x1(%esi),%esi
f0100873:	eb 79                	jmp    f01008ee <monitor+0xce>
		if (*buf == 0)
f0100875:	80 3e 00             	cmpb   $0x0,(%esi)
f0100878:	74 7f                	je     f01008f9 <monitor+0xd9>
		if (argc == MAXARGS-1) {
f010087a:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f010087e:	74 0f                	je     f010088f <monitor+0x6f>
		argv[argc++] = buf;
f0100880:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100883:	8d 48 01             	lea    0x1(%eax),%ecx
f0100886:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100889:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f010088d:	eb 44                	jmp    f01008d3 <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010088f:	83 ec 08             	sub    $0x8,%esp
f0100892:	6a 10                	push   $0x10
f0100894:	8d 83 cf cf fe ff    	lea    -0x13031(%ebx),%eax
f010089a:	50                   	push   %eax
f010089b:	e8 a9 27 00 00       	call   f0103049 <cprintf>
f01008a0:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01008a3:	8d 83 c6 cf fe ff    	lea    -0x1303a(%ebx),%eax
f01008a9:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01008ac:	83 ec 0c             	sub    $0xc,%esp
f01008af:	ff 75 a4             	pushl  -0x5c(%ebp)
f01008b2:	e8 79 30 00 00       	call   f0103930 <readline>
f01008b7:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01008b9:	83 c4 10             	add    $0x10,%esp
f01008bc:	85 c0                	test   %eax,%eax
f01008be:	74 ec                	je     f01008ac <monitor+0x8c>
	argv[argc] = 0;
f01008c0:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01008c7:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01008ce:	eb 1e                	jmp    f01008ee <monitor+0xce>
			buf++;
f01008d0:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008d3:	0f b6 06             	movzbl (%esi),%eax
f01008d6:	84 c0                	test   %al,%al
f01008d8:	74 14                	je     f01008ee <monitor+0xce>
f01008da:	83 ec 08             	sub    $0x8,%esp
f01008dd:	0f be c0             	movsbl %al,%eax
f01008e0:	50                   	push   %eax
f01008e1:	57                   	push   %edi
f01008e2:	e8 81 32 00 00       	call   f0103b68 <strchr>
f01008e7:	83 c4 10             	add    $0x10,%esp
f01008ea:	85 c0                	test   %eax,%eax
f01008ec:	74 e2                	je     f01008d0 <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f01008ee:	0f b6 06             	movzbl (%esi),%eax
f01008f1:	84 c0                	test   %al,%al
f01008f3:	0f 85 60 ff ff ff    	jne    f0100859 <monitor+0x39>
	argv[argc] = 0;
f01008f9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01008fc:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100903:	00 
	if (argc == 0)
f0100904:	85 c0                	test   %eax,%eax
f0100906:	74 9b                	je     f01008a3 <monitor+0x83>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100908:	83 ec 08             	sub    $0x8,%esp
f010090b:	8d 83 96 cf fe ff    	lea    -0x1306a(%ebx),%eax
f0100911:	50                   	push   %eax
f0100912:	ff 75 a8             	pushl  -0x58(%ebp)
f0100915:	e8 f0 31 00 00       	call   f0103b0a <strcmp>
f010091a:	83 c4 10             	add    $0x10,%esp
f010091d:	85 c0                	test   %eax,%eax
f010091f:	74 38                	je     f0100959 <monitor+0x139>
f0100921:	83 ec 08             	sub    $0x8,%esp
f0100924:	8d 83 a4 cf fe ff    	lea    -0x1305c(%ebx),%eax
f010092a:	50                   	push   %eax
f010092b:	ff 75 a8             	pushl  -0x58(%ebp)
f010092e:	e8 d7 31 00 00       	call   f0103b0a <strcmp>
f0100933:	83 c4 10             	add    $0x10,%esp
f0100936:	85 c0                	test   %eax,%eax
f0100938:	74 1a                	je     f0100954 <monitor+0x134>
	cprintf("Unknown command '%s'\n", argv[0]);
f010093a:	83 ec 08             	sub    $0x8,%esp
f010093d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100940:	8d 83 ec cf fe ff    	lea    -0x13014(%ebx),%eax
f0100946:	50                   	push   %eax
f0100947:	e8 fd 26 00 00       	call   f0103049 <cprintf>
f010094c:	83 c4 10             	add    $0x10,%esp
f010094f:	e9 4f ff ff ff       	jmp    f01008a3 <monitor+0x83>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100954:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100959:	83 ec 04             	sub    $0x4,%esp
f010095c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010095f:	ff 75 08             	pushl  0x8(%ebp)
f0100962:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100965:	52                   	push   %edx
f0100966:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100969:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100970:	83 c4 10             	add    $0x10,%esp
f0100973:	85 c0                	test   %eax,%eax
f0100975:	0f 89 28 ff ff ff    	jns    f01008a3 <monitor+0x83>
				break;
	}
}
f010097b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010097e:	5b                   	pop    %ebx
f010097f:	5e                   	pop    %esi
f0100980:	5f                   	pop    %edi
f0100981:	5d                   	pop    %ebp
f0100982:	c3                   	ret    

f0100983 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100983:	e8 2e 26 00 00       	call   f0102fb6 <__x86.get_pc_thunk.dx>
f0100988:	81 c2 80 69 01 00    	add    $0x16980,%edx
f010098e:	89 c1                	mov    %eax,%ecx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100990:	83 ba 90 1f 00 00 00 	cmpl   $0x0,0x1f90(%edx)
f0100997:	74 3e                	je     f01009d7 <boot_alloc+0x54>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n > 0) {
f0100999:	85 c9                	test   %ecx,%ecx
f010099b:	74 6c                	je     f0100a09 <boot_alloc+0x86>
{
f010099d:	55                   	push   %ebp
f010099e:	89 e5                	mov    %esp,%ebp
f01009a0:	53                   	push   %ebx
f01009a1:	83 ec 04             	sub    $0x4,%esp
		result = nextfree;
f01009a4:	8b 82 90 1f 00 00    	mov    0x1f90(%edx),%eax
		nextfree = ROUNDUP((char*)(nextfree+n), PGSIZE);
f01009aa:	8d 8c 08 ff 0f 00 00 	lea    0xfff(%eax,%ecx,1),%ecx
f01009b1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01009b7:	89 8a 90 1f 00 00    	mov    %ecx,0x1f90(%edx)
		if((uint32_t)nextfree - KERNBASE > (npages*PGSIZE))
f01009bd:	81 c1 00 00 00 10    	add    $0x10000000,%ecx
f01009c3:	c7 c3 c8 96 11 f0    	mov    $0xf01196c8,%ebx
f01009c9:	8b 1b                	mov    (%ebx),%ebx
f01009cb:	c1 e3 0c             	shl    $0xc,%ebx
f01009ce:	39 d9                	cmp    %ebx,%ecx
f01009d0:	77 1d                	ja     f01009ef <boot_alloc+0x6c>
		return result;
	}
	else if(n == 0)
		return nextfree;
	return NULL;
}
f01009d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01009d5:	c9                   	leave  
f01009d6:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01009d7:	c7 c0 c0 96 11 f0    	mov    $0xf01196c0,%eax
f01009dd:	05 ff 0f 00 00       	add    $0xfff,%eax
f01009e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009e7:	89 82 90 1f 00 00    	mov    %eax,0x1f90(%edx)
f01009ed:	eb aa                	jmp    f0100999 <boot_alloc+0x16>
			panic("Out Of Memory!\n");
f01009ef:	83 ec 04             	sub    $0x4,%esp
f01009f2:	8d 82 59 d1 fe ff    	lea    -0x12ea7(%edx),%eax
f01009f8:	50                   	push   %eax
f01009f9:	6a 6c                	push   $0x6c
f01009fb:	8d 82 69 d1 fe ff    	lea    -0x12e97(%edx),%eax
f0100a01:	50                   	push   %eax
f0100a02:	89 d3                	mov    %edx,%ebx
f0100a04:	e8 90 f6 ff ff       	call   f0100099 <_panic>
		return nextfree;
f0100a09:	8b 82 90 1f 00 00    	mov    0x1f90(%edx),%eax
}
f0100a0f:	c3                   	ret    

f0100a10 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a10:	55                   	push   %ebp
f0100a11:	89 e5                	mov    %esp,%ebp
f0100a13:	56                   	push   %esi
f0100a14:	53                   	push   %ebx
f0100a15:	e8 a0 25 00 00       	call   f0102fba <__x86.get_pc_thunk.cx>
f0100a1a:	81 c1 ee 68 01 00    	add    $0x168ee,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a20:	89 d3                	mov    %edx,%ebx
f0100a22:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0100a25:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100a28:	a8 01                	test   $0x1,%al
f0100a2a:	74 5a                	je     f0100a86 <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a31:	89 c6                	mov    %eax,%esi
f0100a33:	c1 ee 0c             	shr    $0xc,%esi
f0100a36:	c7 c3 c8 96 11 f0    	mov    $0xf01196c8,%ebx
f0100a3c:	3b 33                	cmp    (%ebx),%esi
f0100a3e:	73 2b                	jae    f0100a6b <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0100a40:	c1 ea 0c             	shr    $0xc,%edx
f0100a43:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a49:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a50:	89 c2                	mov    %eax,%edx
f0100a52:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a55:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a5a:	85 d2                	test   %edx,%edx
f0100a5c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a61:	0f 44 c2             	cmove  %edx,%eax
}
f0100a64:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a67:	5b                   	pop    %ebx
f0100a68:	5e                   	pop    %esi
f0100a69:	5d                   	pop    %ebp
f0100a6a:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a6b:	50                   	push   %eax
f0100a6c:	8d 81 bc d4 fe ff    	lea    -0x12b44(%ecx),%eax
f0100a72:	50                   	push   %eax
f0100a73:	68 f1 02 00 00       	push   $0x2f1
f0100a78:	8d 81 69 d1 fe ff    	lea    -0x12e97(%ecx),%eax
f0100a7e:	50                   	push   %eax
f0100a7f:	89 cb                	mov    %ecx,%ebx
f0100a81:	e8 13 f6 ff ff       	call   f0100099 <_panic>
		return ~0;
f0100a86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100a8b:	eb d7                	jmp    f0100a64 <check_va2pa+0x54>

f0100a8d <check_page_free_list>:
{
f0100a8d:	55                   	push   %ebp
f0100a8e:	89 e5                	mov    %esp,%ebp
f0100a90:	57                   	push   %edi
f0100a91:	56                   	push   %esi
f0100a92:	53                   	push   %ebx
f0100a93:	83 ec 3c             	sub    $0x3c,%esp
f0100a96:	e8 b4 f6 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100a9b:	81 c3 6d 68 01 00    	add    $0x1686d,%ebx
f0100aa1:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100aa4:	84 c0                	test   %al,%al
f0100aa6:	0f 85 72 03 00 00    	jne    f0100e1e <check_page_free_list+0x391>
	if (!page_free_list)
f0100aac:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100aaf:	83 b8 94 1f 00 00 00 	cmpl   $0x0,0x1f94(%eax)
f0100ab6:	74 3e                	je     f0100af6 <check_page_free_list+0x69>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ab8:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
	cprintf("after hanling low memory question, page_free_list is %x now\n", page_free_list);
f0100abf:	83 ec 08             	sub    $0x8,%esp
f0100ac2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ac5:	ff b7 94 1f 00 00    	pushl  0x1f94(%edi)
f0100acb:	8d 87 44 d5 fe ff    	lea    -0x12abc(%edi),%eax
f0100ad1:	50                   	push   %eax
f0100ad2:	89 fb                	mov    %edi,%ebx
f0100ad4:	e8 70 25 00 00       	call   f0103049 <cprintf>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ad9:	8b b7 94 1f 00 00    	mov    0x1f94(%edi),%esi
f0100adf:	83 c4 10             	add    $0x10,%esp
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ae2:	c7 c7 d0 96 11 f0    	mov    $0xf01196d0,%edi
	if (PGNUM(pa) >= npages)
f0100ae8:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0100aee:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100af1:	e9 82 00 00 00       	jmp    f0100b78 <check_page_free_list+0xeb>
		panic("'page_free_list' is a null pointer!");
f0100af6:	83 ec 04             	sub    $0x4,%esp
f0100af9:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100afc:	8d 83 e0 d4 fe ff    	lea    -0x12b20(%ebx),%eax
f0100b02:	50                   	push   %eax
f0100b03:	68 26 02 00 00       	push   $0x226
f0100b08:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0100b0e:	50                   	push   %eax
f0100b0f:	e8 85 f5 ff ff       	call   f0100099 <_panic>
	return (pp - pages) << PGSHIFT;
f0100b14:	89 c2                	mov    %eax,%edx
f0100b16:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b18:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b1e:	0f 95 c2             	setne  %dl
f0100b21:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b24:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b28:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b2a:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b2e:	8b 00                	mov    (%eax),%eax
f0100b30:	85 c0                	test   %eax,%eax
f0100b32:	75 e0                	jne    f0100b14 <check_page_free_list+0x87>
		*tp[1] = 0;
f0100b34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b40:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b43:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b45:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b48:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100b4b:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b51:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
f0100b58:	e9 62 ff ff ff       	jmp    f0100abf <check_page_free_list+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b5d:	50                   	push   %eax
f0100b5e:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100b61:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f0100b67:	50                   	push   %eax
f0100b68:	6a 52                	push   $0x52
f0100b6a:	8d 83 75 d1 fe ff    	lea    -0x12e8b(%ebx),%eax
f0100b70:	50                   	push   %eax
f0100b71:	e8 23 f5 ff ff       	call   f0100099 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b76:	8b 36                	mov    (%esi),%esi
f0100b78:	85 f6                	test   %esi,%esi
f0100b7a:	74 40                	je     f0100bbc <check_page_free_list+0x12f>
	return (pp - pages) << PGSHIFT;
f0100b7c:	89 f0                	mov    %esi,%eax
f0100b7e:	2b 07                	sub    (%edi),%eax
f0100b80:	c1 f8 03             	sar    $0x3,%eax
f0100b83:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b86:	89 c2                	mov    %eax,%edx
f0100b88:	c1 ea 16             	shr    $0x16,%edx
f0100b8b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b8e:	73 e6                	jae    f0100b76 <check_page_free_list+0xe9>
	if (PGNUM(pa) >= npages)
f0100b90:	89 c2                	mov    %eax,%edx
f0100b92:	c1 ea 0c             	shr    $0xc,%edx
f0100b95:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100b98:	3b 13                	cmp    (%ebx),%edx
f0100b9a:	73 c1                	jae    f0100b5d <check_page_free_list+0xd0>
			memset(page2kva(pp), 0x97, 128);
f0100b9c:	83 ec 04             	sub    $0x4,%esp
f0100b9f:	68 80 00 00 00       	push   $0x80
f0100ba4:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100ba9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bae:	50                   	push   %eax
f0100baf:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100bb2:	e8 ee 2f 00 00       	call   f0103ba5 <memset>
f0100bb7:	83 c4 10             	add    $0x10,%esp
f0100bba:	eb ba                	jmp    f0100b76 <check_page_free_list+0xe9>
	first_free_page = (char *) boot_alloc(0);
f0100bbc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bc1:	e8 bd fd ff ff       	call   f0100983 <boot_alloc>
f0100bc6:	89 45 c8             	mov    %eax,-0x38(%ebp)
	cprintf("first_free_page is %x\n", first_free_page);
f0100bc9:	83 ec 08             	sub    $0x8,%esp
f0100bcc:	50                   	push   %eax
f0100bcd:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100bd0:	8d 87 83 d1 fe ff    	lea    -0x12e7d(%edi),%eax
f0100bd6:	50                   	push   %eax
f0100bd7:	89 fb                	mov    %edi,%ebx
f0100bd9:	e8 6b 24 00 00       	call   f0103049 <cprintf>
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bde:	8b 97 94 1f 00 00    	mov    0x1f94(%edi),%edx
		assert(pp >= pages);
f0100be4:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0100bea:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0100bec:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0100bf2:	8b 00                	mov    (%eax),%eax
f0100bf4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100bf7:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bfa:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bfd:	83 c4 10             	add    $0x10,%esp
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c00:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c05:	89 75 d0             	mov    %esi,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c08:	e9 08 01 00 00       	jmp    f0100d15 <check_page_free_list+0x288>
		assert(pp >= pages);
f0100c0d:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c10:	8d 83 9a d1 fe ff    	lea    -0x12e66(%ebx),%eax
f0100c16:	50                   	push   %eax
f0100c17:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0100c1d:	50                   	push   %eax
f0100c1e:	68 46 02 00 00       	push   $0x246
f0100c23:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0100c29:	50                   	push   %eax
f0100c2a:	e8 6a f4 ff ff       	call   f0100099 <_panic>
		assert(pp < pages + npages);
f0100c2f:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c32:	8d 83 bb d1 fe ff    	lea    -0x12e45(%ebx),%eax
f0100c38:	50                   	push   %eax
f0100c39:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0100c3f:	50                   	push   %eax
f0100c40:	68 47 02 00 00       	push   $0x247
f0100c45:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0100c4b:	50                   	push   %eax
f0100c4c:	e8 48 f4 ff ff       	call   f0100099 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c51:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c54:	8d 83 84 d5 fe ff    	lea    -0x12a7c(%ebx),%eax
f0100c5a:	50                   	push   %eax
f0100c5b:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0100c61:	50                   	push   %eax
f0100c62:	68 48 02 00 00       	push   $0x248
f0100c67:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0100c6d:	50                   	push   %eax
f0100c6e:	e8 26 f4 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != 0);
f0100c73:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c76:	8d 83 cf d1 fe ff    	lea    -0x12e31(%ebx),%eax
f0100c7c:	50                   	push   %eax
f0100c7d:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0100c83:	50                   	push   %eax
f0100c84:	68 4b 02 00 00       	push   $0x24b
f0100c89:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0100c8f:	50                   	push   %eax
f0100c90:	e8 04 f4 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c95:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c98:	8d 83 e0 d1 fe ff    	lea    -0x12e20(%ebx),%eax
f0100c9e:	50                   	push   %eax
f0100c9f:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0100ca5:	50                   	push   %eax
f0100ca6:	68 4c 02 00 00       	push   $0x24c
f0100cab:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0100cb1:	50                   	push   %eax
f0100cb2:	e8 e2 f3 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cb7:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cba:	8d 83 b8 d5 fe ff    	lea    -0x12a48(%ebx),%eax
f0100cc0:	50                   	push   %eax
f0100cc1:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0100cc7:	50                   	push   %eax
f0100cc8:	68 4d 02 00 00       	push   $0x24d
f0100ccd:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0100cd3:	50                   	push   %eax
f0100cd4:	e8 c0 f3 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cd9:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cdc:	8d 83 f9 d1 fe ff    	lea    -0x12e07(%ebx),%eax
f0100ce2:	50                   	push   %eax
f0100ce3:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0100ce9:	50                   	push   %eax
f0100cea:	68 4e 02 00 00       	push   $0x24e
f0100cef:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0100cf5:	50                   	push   %eax
f0100cf6:	e8 9e f3 ff ff       	call   f0100099 <_panic>
	if (PGNUM(pa) >= npages)
f0100cfb:	89 c6                	mov    %eax,%esi
f0100cfd:	c1 ee 0c             	shr    $0xc,%esi
f0100d00:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0100d03:	76 70                	jbe    f0100d75 <check_page_free_list+0x2e8>
	return (void *)(pa + KERNBASE);
f0100d05:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d0a:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100d0d:	77 7f                	ja     f0100d8e <check_page_free_list+0x301>
			++nfree_extmem;
f0100d0f:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d13:	8b 12                	mov    (%edx),%edx
f0100d15:	85 d2                	test   %edx,%edx
f0100d17:	0f 84 93 00 00 00    	je     f0100db0 <check_page_free_list+0x323>
		assert(pp >= pages);
f0100d1d:	39 d1                	cmp    %edx,%ecx
f0100d1f:	0f 87 e8 fe ff ff    	ja     f0100c0d <check_page_free_list+0x180>
		assert(pp < pages + npages);
f0100d25:	39 d3                	cmp    %edx,%ebx
f0100d27:	0f 86 02 ff ff ff    	jbe    f0100c2f <check_page_free_list+0x1a2>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d2d:	89 d0                	mov    %edx,%eax
f0100d2f:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100d32:	a8 07                	test   $0x7,%al
f0100d34:	0f 85 17 ff ff ff    	jne    f0100c51 <check_page_free_list+0x1c4>
	return (pp - pages) << PGSHIFT;
f0100d3a:	c1 f8 03             	sar    $0x3,%eax
f0100d3d:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100d40:	85 c0                	test   %eax,%eax
f0100d42:	0f 84 2b ff ff ff    	je     f0100c73 <check_page_free_list+0x1e6>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d48:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d4d:	0f 84 42 ff ff ff    	je     f0100c95 <check_page_free_list+0x208>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d53:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d58:	0f 84 59 ff ff ff    	je     f0100cb7 <check_page_free_list+0x22a>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d5e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d63:	0f 84 70 ff ff ff    	je     f0100cd9 <check_page_free_list+0x24c>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d69:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d6e:	77 8b                	ja     f0100cfb <check_page_free_list+0x26e>
			++nfree_basemem;
f0100d70:	83 c7 01             	add    $0x1,%edi
f0100d73:	eb 9e                	jmp    f0100d13 <check_page_free_list+0x286>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d75:	50                   	push   %eax
f0100d76:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d79:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f0100d7f:	50                   	push   %eax
f0100d80:	6a 52                	push   $0x52
f0100d82:	8d 83 75 d1 fe ff    	lea    -0x12e8b(%ebx),%eax
f0100d88:	50                   	push   %eax
f0100d89:	e8 0b f3 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d8e:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d91:	8d 83 dc d5 fe ff    	lea    -0x12a24(%ebx),%eax
f0100d97:	50                   	push   %eax
f0100d98:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0100d9e:	50                   	push   %eax
f0100d9f:	68 4f 02 00 00       	push   $0x24f
f0100da4:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0100daa:	50                   	push   %eax
f0100dab:	e8 e9 f2 ff ff       	call   f0100099 <_panic>
f0100db0:	8b 75 d0             	mov    -0x30(%ebp),%esi
	cprintf("nfree_basemem is %d, nfree_extmem is %d\n", nfree_basemem, nfree_extmem);
f0100db3:	83 ec 04             	sub    $0x4,%esp
f0100db6:	56                   	push   %esi
f0100db7:	57                   	push   %edi
f0100db8:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dbb:	8d 83 24 d6 fe ff    	lea    -0x129dc(%ebx),%eax
f0100dc1:	50                   	push   %eax
f0100dc2:	e8 82 22 00 00       	call   f0103049 <cprintf>
	assert(nfree_basemem > 0);
f0100dc7:	83 c4 10             	add    $0x10,%esp
f0100dca:	85 ff                	test   %edi,%edi
f0100dcc:	7e 0c                	jle    f0100dda <check_page_free_list+0x34d>
	assert(nfree_extmem > 0);
f0100dce:	85 f6                	test   %esi,%esi
f0100dd0:	7e 2a                	jle    f0100dfc <check_page_free_list+0x36f>
}
f0100dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dd5:	5b                   	pop    %ebx
f0100dd6:	5e                   	pop    %esi
f0100dd7:	5f                   	pop    %edi
f0100dd8:	5d                   	pop    %ebp
f0100dd9:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100dda:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ddd:	8d 83 13 d2 fe ff    	lea    -0x12ded(%ebx),%eax
f0100de3:	50                   	push   %eax
f0100de4:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0100dea:	50                   	push   %eax
f0100deb:	68 58 02 00 00       	push   $0x258
f0100df0:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0100df6:	50                   	push   %eax
f0100df7:	e8 9d f2 ff ff       	call   f0100099 <_panic>
	assert(nfree_extmem > 0);
f0100dfc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dff:	8d 83 25 d2 fe ff    	lea    -0x12ddb(%ebx),%eax
f0100e05:	50                   	push   %eax
f0100e06:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0100e0c:	50                   	push   %eax
f0100e0d:	68 59 02 00 00       	push   $0x259
f0100e12:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0100e18:	50                   	push   %eax
f0100e19:	e8 7b f2 ff ff       	call   f0100099 <_panic>
	if (!page_free_list)
f0100e1e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100e21:	8b 80 94 1f 00 00    	mov    0x1f94(%eax),%eax
f0100e27:	85 c0                	test   %eax,%eax
f0100e29:	0f 84 c7 fc ff ff    	je     f0100af6 <check_page_free_list+0x69>
		cprintf("before hanling low memory question, page_free_list is %x now\n", page_free_list);
f0100e2f:	83 ec 08             	sub    $0x8,%esp
f0100e32:	50                   	push   %eax
f0100e33:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100e36:	8d 87 04 d5 fe ff    	lea    -0x12afc(%edi),%eax
f0100e3c:	50                   	push   %eax
f0100e3d:	89 fb                	mov    %edi,%ebx
f0100e3f:	e8 05 22 00 00       	call   f0103049 <cprintf>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e44:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0100e47:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e4a:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0100e4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e50:	8b 87 94 1f 00 00    	mov    0x1f94(%edi),%eax
f0100e56:	83 c4 10             	add    $0x10,%esp
	return (pp - pages) << PGSHIFT;
f0100e59:	c7 c3 d0 96 11 f0    	mov    $0xf01196d0,%ebx
f0100e5f:	e9 cc fc ff ff       	jmp    f0100b30 <check_page_free_list+0xa3>

f0100e64 <page_init>:
{
f0100e64:	55                   	push   %ebp
f0100e65:	89 e5                	mov    %esp,%ebp
f0100e67:	57                   	push   %edi
f0100e68:	56                   	push   %esi
f0100e69:	53                   	push   %ebx
f0100e6a:	83 ec 1c             	sub    $0x1c,%esp
f0100e6d:	e8 4c 21 00 00       	call   f0102fbe <__x86.get_pc_thunk.di>
f0100e72:	81 c7 96 64 01 00    	add    $0x16496,%edi
f0100e78:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	page_free_list = NULL;
f0100e7b:	c7 87 94 1f 00 00 00 	movl   $0x0,0x1f94(%edi)
f0100e82:	00 00 00 
	int num_alloc = ((uint32_t)boot_alloc(0) - KERNBASE) / PGSIZE;
f0100e85:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e8a:	e8 f4 fa ff ff       	call   f0100983 <boot_alloc>
f0100e8f:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e94:	c1 e8 0c             	shr    $0xc,%eax
f0100e97:	89 45 e0             	mov    %eax,-0x20(%ebp)
	pages[0].pp_ref = 1;
f0100e9a:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0100ea0:	8b 00                	mov    (%eax),%eax
f0100ea2:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	for(i = 1; i < npages_basemem; i++)
f0100ea8:	8b b7 98 1f 00 00    	mov    0x1f98(%edi),%esi
f0100eae:	ba 00 00 00 00       	mov    $0x0,%edx
f0100eb3:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100eb8:	b8 01 00 00 00       	mov    $0x1,%eax
		pages[i].pp_ref = 0;
f0100ebd:	c7 c7 d0 96 11 f0    	mov    $0xf01196d0,%edi
	for(i = 1; i < npages_basemem; i++)
f0100ec3:	eb 1f                	jmp    f0100ee4 <page_init+0x80>
		pages[i].pp_ref = 0;
f0100ec5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100ecc:	89 d1                	mov    %edx,%ecx
f0100ece:	03 0f                	add    (%edi),%ecx
f0100ed0:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100ed6:	89 19                	mov    %ebx,(%ecx)
	for(i = 1; i < npages_basemem; i++)
f0100ed8:	83 c0 01             	add    $0x1,%eax
		page_free_list = &pages[i];
f0100edb:	89 d3                	mov    %edx,%ebx
f0100edd:	03 1f                	add    (%edi),%ebx
f0100edf:	ba 01 00 00 00       	mov    $0x1,%edx
	for(i = 1; i < npages_basemem; i++)
f0100ee4:	39 c6                	cmp    %eax,%esi
f0100ee6:	77 dd                	ja     f0100ec5 <page_init+0x61>
f0100ee8:	84 d2                	test   %dl,%dl
f0100eea:	75 16                	jne    f0100f02 <page_init+0x9e>
		pages[i].pp_ref = 1;
f0100eec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100eef:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0100ef5:	8b 08                	mov    (%eax),%ecx
	for(i = npages_basemem; i < npages_basemem + num_iohole + num_alloc; i++)
f0100ef7:	89 f0                	mov    %esi,%eax
f0100ef9:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100efc:	8d 54 37 60          	lea    0x60(%edi,%esi,1),%edx
f0100f00:	eb 15                	jmp    f0100f17 <page_init+0xb3>
f0100f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f05:	89 98 94 1f 00 00    	mov    %ebx,0x1f94(%eax)
f0100f0b:	eb df                	jmp    f0100eec <page_init+0x88>
		pages[i].pp_ref = 1;
f0100f0d:	66 c7 44 c1 04 01 00 	movw   $0x1,0x4(%ecx,%eax,8)
	for(i = npages_basemem; i < npages_basemem + num_iohole + num_alloc; i++)
f0100f14:	83 c0 01             	add    $0x1,%eax
f0100f17:	39 c2                	cmp    %eax,%edx
f0100f19:	77 f2                	ja     f0100f0d <page_init+0xa9>
f0100f1b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f1e:	8b 9e 94 1f 00 00    	mov    0x1f94(%esi),%ebx
f0100f24:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100f2b:	b9 00 00 00 00       	mov    $0x0,%ecx
	for(; i < npages; i++)
f0100f30:	c7 c7 c8 96 11 f0    	mov    $0xf01196c8,%edi
		pages[i].pp_ref = 0;
f0100f36:	c7 c6 d0 96 11 f0    	mov    $0xf01196d0,%esi
f0100f3c:	eb 1b                	jmp    f0100f59 <page_init+0xf5>
f0100f3e:	89 d1                	mov    %edx,%ecx
f0100f40:	03 0e                	add    (%esi),%ecx
f0100f42:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100f48:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100f4a:	89 d3                	mov    %edx,%ebx
f0100f4c:	03 1e                	add    (%esi),%ebx
	for(; i < npages; i++)
f0100f4e:	83 c0 01             	add    $0x1,%eax
f0100f51:	83 c2 08             	add    $0x8,%edx
f0100f54:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100f59:	39 07                	cmp    %eax,(%edi)
f0100f5b:	77 e1                	ja     f0100f3e <page_init+0xda>
f0100f5d:	84 c9                	test   %cl,%cl
f0100f5f:	75 08                	jne    f0100f69 <page_init+0x105>
}
f0100f61:	83 c4 1c             	add    $0x1c,%esp
f0100f64:	5b                   	pop    %ebx
f0100f65:	5e                   	pop    %esi
f0100f66:	5f                   	pop    %edi
f0100f67:	5d                   	pop    %ebp
f0100f68:	c3                   	ret    
f0100f69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f6c:	89 98 94 1f 00 00    	mov    %ebx,0x1f94(%eax)
f0100f72:	eb ed                	jmp    f0100f61 <page_init+0xfd>

f0100f74 <page_alloc>:
{
f0100f74:	55                   	push   %ebp
f0100f75:	89 e5                	mov    %esp,%ebp
f0100f77:	56                   	push   %esi
f0100f78:	53                   	push   %ebx
f0100f79:	e8 d1 f1 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100f7e:	81 c3 8a 63 01 00    	add    $0x1638a,%ebx
	if(!page_free_list)
f0100f84:	8b b3 94 1f 00 00    	mov    0x1f94(%ebx),%esi
f0100f8a:	85 f6                	test   %esi,%esi
f0100f8c:	74 14                	je     f0100fa2 <page_alloc+0x2e>
	if(alloc_flags & ALLOC_ZERO) {
f0100f8e:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f92:	75 17                	jne    f0100fab <page_alloc+0x37>
	page_free_list = pp->pp_link;
f0100f94:	8b 06                	mov    (%esi),%eax
f0100f96:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
	pp->pp_link = 0;
f0100f9c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
}
f0100fa2:	89 f0                	mov    %esi,%eax
f0100fa4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fa7:	5b                   	pop    %ebx
f0100fa8:	5e                   	pop    %esi
f0100fa9:	5d                   	pop    %ebp
f0100faa:	c3                   	ret    
f0100fab:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0100fb1:	89 f2                	mov    %esi,%edx
f0100fb3:	2b 10                	sub    (%eax),%edx
f0100fb5:	89 d0                	mov    %edx,%eax
f0100fb7:	c1 f8 03             	sar    $0x3,%eax
f0100fba:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100fbd:	89 c1                	mov    %eax,%ecx
f0100fbf:	c1 e9 0c             	shr    $0xc,%ecx
f0100fc2:	c7 c2 c8 96 11 f0    	mov    $0xf01196c8,%edx
f0100fc8:	3b 0a                	cmp    (%edx),%ecx
f0100fca:	73 1a                	jae    f0100fe6 <page_alloc+0x72>
		memset(page2kva(pp), 0, PGSIZE);
f0100fcc:	83 ec 04             	sub    $0x4,%esp
f0100fcf:	68 00 10 00 00       	push   $0x1000
f0100fd4:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fd6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fdb:	50                   	push   %eax
f0100fdc:	e8 c4 2b 00 00       	call   f0103ba5 <memset>
f0100fe1:	83 c4 10             	add    $0x10,%esp
f0100fe4:	eb ae                	jmp    f0100f94 <page_alloc+0x20>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fe6:	50                   	push   %eax
f0100fe7:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f0100fed:	50                   	push   %eax
f0100fee:	6a 52                	push   $0x52
f0100ff0:	8d 83 75 d1 fe ff    	lea    -0x12e8b(%ebx),%eax
f0100ff6:	50                   	push   %eax
f0100ff7:	e8 9d f0 ff ff       	call   f0100099 <_panic>

f0100ffc <page_free>:
{
f0100ffc:	55                   	push   %ebp
f0100ffd:	89 e5                	mov    %esp,%ebp
f0100fff:	53                   	push   %ebx
f0101000:	83 ec 04             	sub    $0x4,%esp
f0101003:	e8 47 f1 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0101008:	81 c3 00 63 01 00    	add    $0x16300,%ebx
f010100e:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_ref != 0)
f0101011:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101016:	75 18                	jne    f0101030 <page_free+0x34>
	if(pp->pp_link)
f0101018:	83 38 00             	cmpl   $0x0,(%eax)
f010101b:	75 2e                	jne    f010104b <page_free+0x4f>
	pp->pp_link = page_free_list;
f010101d:	8b 8b 94 1f 00 00    	mov    0x1f94(%ebx),%ecx
f0101023:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f0101025:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
}
f010102b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010102e:	c9                   	leave  
f010102f:	c3                   	ret    
		panic("pp->pp_ref is nonzero\n");
f0101030:	83 ec 04             	sub    $0x4,%esp
f0101033:	8d 83 36 d2 fe ff    	lea    -0x12dca(%ebx),%eax
f0101039:	50                   	push   %eax
f010103a:	68 4c 01 00 00       	push   $0x14c
f010103f:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0101045:	50                   	push   %eax
f0101046:	e8 4e f0 ff ff       	call   f0100099 <_panic>
		panic("pp->pp_link is not NULL\n");
f010104b:	83 ec 04             	sub    $0x4,%esp
f010104e:	8d 83 4d d2 fe ff    	lea    -0x12db3(%ebx),%eax
f0101054:	50                   	push   %eax
f0101055:	68 4e 01 00 00       	push   $0x14e
f010105a:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0101060:	50                   	push   %eax
f0101061:	e8 33 f0 ff ff       	call   f0100099 <_panic>

f0101066 <page_decref>:
{
f0101066:	55                   	push   %ebp
f0101067:	89 e5                	mov    %esp,%ebp
f0101069:	83 ec 08             	sub    $0x8,%esp
f010106c:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010106f:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101073:	83 e8 01             	sub    $0x1,%eax
f0101076:	66 89 42 04          	mov    %ax,0x4(%edx)
f010107a:	66 85 c0             	test   %ax,%ax
f010107d:	74 02                	je     f0101081 <page_decref+0x1b>
}
f010107f:	c9                   	leave  
f0101080:	c3                   	ret    
		page_free(pp);
f0101081:	83 ec 0c             	sub    $0xc,%esp
f0101084:	52                   	push   %edx
f0101085:	e8 72 ff ff ff       	call   f0100ffc <page_free>
f010108a:	83 c4 10             	add    $0x10,%esp
}
f010108d:	eb f0                	jmp    f010107f <page_decref+0x19>

f010108f <pgdir_walk>:
{
f010108f:	55                   	push   %ebp
f0101090:	89 e5                	mov    %esp,%ebp
f0101092:	57                   	push   %edi
f0101093:	56                   	push   %esi
f0101094:	53                   	push   %ebx
f0101095:	83 ec 0c             	sub    $0xc,%esp
f0101098:	e8 b2 f0 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010109d:	81 c3 6b 62 01 00    	add    $0x1626b,%ebx
f01010a3:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t pde = pgdir[PDX(va)];
f01010a6:	89 f7                	mov    %esi,%edi
f01010a8:	c1 ef 16             	shr    $0x16,%edi
f01010ab:	c1 e7 02             	shl    $0x2,%edi
f01010ae:	03 7d 08             	add    0x8(%ebp),%edi
f01010b1:	8b 07                	mov    (%edi),%eax
	if(pde & PTE_P)
f01010b3:	a8 01                	test   $0x1,%al
f01010b5:	74 45                	je     f01010fc <pgdir_walk+0x6d>
		pte_t * pg_table_p = KADDR(PTE_ADDR(pde));
f01010b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01010bc:	89 c2                	mov    %eax,%edx
f01010be:	c1 ea 0c             	shr    $0xc,%edx
f01010c1:	c7 c1 c8 96 11 f0    	mov    $0xf01196c8,%ecx
f01010c7:	39 11                	cmp    %edx,(%ecx)
f01010c9:	76 18                	jbe    f01010e3 <pgdir_walk+0x54>
		result = pg_table_p + PTX(va);
f01010cb:	c1 ee 0a             	shr    $0xa,%esi
f01010ce:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010d4:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
}
f01010db:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010de:	5b                   	pop    %ebx
f01010df:	5e                   	pop    %esi
f01010e0:	5f                   	pop    %edi
f01010e1:	5d                   	pop    %ebp
f01010e2:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010e3:	50                   	push   %eax
f01010e4:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f01010ea:	50                   	push   %eax
f01010eb:	68 7d 01 00 00       	push   $0x17d
f01010f0:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01010f6:	50                   	push   %eax
f01010f7:	e8 9d ef ff ff       	call   f0100099 <_panic>
	else if(!create)
f01010fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101100:	74 6d                	je     f010116f <pgdir_walk+0xe0>
		struct PageInfo *pp = page_alloc(1);
f0101102:	83 ec 0c             	sub    $0xc,%esp
f0101105:	6a 01                	push   $0x1
f0101107:	e8 68 fe ff ff       	call   f0100f74 <page_alloc>
		if(!pp)
f010110c:	83 c4 10             	add    $0x10,%esp
f010110f:	85 c0                	test   %eax,%eax
f0101111:	74 66                	je     f0101179 <pgdir_walk+0xea>
			pp->pp_ref++;
f0101113:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101118:	c7 c1 d0 96 11 f0    	mov    $0xf01196d0,%ecx
f010111e:	89 c2                	mov    %eax,%edx
f0101120:	2b 11                	sub    (%ecx),%edx
f0101122:	c1 fa 03             	sar    $0x3,%edx
f0101125:	c1 e2 0c             	shl    $0xc,%edx
			pgdir[PDX(va)] = page2pa(pp) | PTE_P | PTE_W;
f0101128:	83 ca 03             	or     $0x3,%edx
f010112b:	89 17                	mov    %edx,(%edi)
f010112d:	2b 01                	sub    (%ecx),%eax
f010112f:	c1 f8 03             	sar    $0x3,%eax
f0101132:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101135:	89 c1                	mov    %eax,%ecx
f0101137:	c1 e9 0c             	shr    $0xc,%ecx
f010113a:	c7 c2 c8 96 11 f0    	mov    $0xf01196c8,%edx
f0101140:	3b 0a                	cmp    (%edx),%ecx
f0101142:	73 12                	jae    f0101156 <pgdir_walk+0xc7>
			result = pg_table_p + PTX(va);
f0101144:	c1 ee 0a             	shr    $0xa,%esi
f0101147:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010114d:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
			return result;
f0101154:	eb 85                	jmp    f01010db <pgdir_walk+0x4c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101156:	50                   	push   %eax
f0101157:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f010115d:	50                   	push   %eax
f010115e:	68 8c 01 00 00       	push   $0x18c
f0101163:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0101169:	50                   	push   %eax
f010116a:	e8 2a ef ff ff       	call   f0100099 <_panic>
		return NULL;
f010116f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101174:	e9 62 ff ff ff       	jmp    f01010db <pgdir_walk+0x4c>
			return NULL;
f0101179:	b8 00 00 00 00       	mov    $0x0,%eax
f010117e:	e9 58 ff ff ff       	jmp    f01010db <pgdir_walk+0x4c>

f0101183 <boot_map_region>:
{
f0101183:	55                   	push   %ebp
f0101184:	89 e5                	mov    %esp,%ebp
f0101186:	57                   	push   %edi
f0101187:	56                   	push   %esi
f0101188:	53                   	push   %ebx
f0101189:	83 ec 1c             	sub    $0x1c,%esp
f010118c:	e8 2d 1e 00 00       	call   f0102fbe <__x86.get_pc_thunk.di>
f0101191:	81 c7 77 61 01 00    	add    $0x16177,%edi
f0101197:	89 7d d8             	mov    %edi,-0x28(%ebp)
f010119a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010119d:	8b 45 08             	mov    0x8(%ebp),%eax
    for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01011a0:	c1 e9 0c             	shr    $0xc,%ecx
f01011a3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01011a6:	89 c3                	mov    %eax,%ebx
f01011a8:	be 00 00 00 00       	mov    $0x0,%esi
        pte_t *pte = pgdir_walk(pgdir, (void *) va, 1); //create
f01011ad:	89 d7                	mov    %edx,%edi
f01011af:	29 c7                	sub    %eax,%edi
        *pte = pa | perm | PTE_P;
f01011b1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011b4:	83 c8 01             	or     $0x1,%eax
f01011b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01011ba:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f01011bd:	74 48                	je     f0101207 <boot_map_region+0x84>
        pte_t *pte = pgdir_walk(pgdir, (void *) va, 1); //create
f01011bf:	83 ec 04             	sub    $0x4,%esp
f01011c2:	6a 01                	push   $0x1
f01011c4:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01011c7:	50                   	push   %eax
f01011c8:	ff 75 e0             	pushl  -0x20(%ebp)
f01011cb:	e8 bf fe ff ff       	call   f010108f <pgdir_walk>
        if (!pte) panic("boot_map_region panic, out of memory");
f01011d0:	83 c4 10             	add    $0x10,%esp
f01011d3:	85 c0                	test   %eax,%eax
f01011d5:	74 12                	je     f01011e9 <boot_map_region+0x66>
        *pte = pa | perm | PTE_P;
f01011d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01011da:	09 da                	or     %ebx,%edx
f01011dc:	89 10                	mov    %edx,(%eax)
    for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01011de:	83 c6 01             	add    $0x1,%esi
f01011e1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01011e7:	eb d1                	jmp    f01011ba <boot_map_region+0x37>
        if (!pte) panic("boot_map_region panic, out of memory");
f01011e9:	83 ec 04             	sub    $0x4,%esp
f01011ec:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01011ef:	8d 83 50 d6 fe ff    	lea    -0x129b0(%ebx),%eax
f01011f5:	50                   	push   %eax
f01011f6:	68 a3 01 00 00       	push   $0x1a3
f01011fb:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0101201:	50                   	push   %eax
f0101202:	e8 92 ee ff ff       	call   f0100099 <_panic>
}
f0101207:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010120a:	5b                   	pop    %ebx
f010120b:	5e                   	pop    %esi
f010120c:	5f                   	pop    %edi
f010120d:	5d                   	pop    %ebp
f010120e:	c3                   	ret    

f010120f <page_lookup>:
{
f010120f:	55                   	push   %ebp
f0101210:	89 e5                	mov    %esp,%ebp
f0101212:	56                   	push   %esi
f0101213:	53                   	push   %ebx
f0101214:	e8 36 ef ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0101219:	81 c3 ef 60 01 00    	add    $0x160ef,%ebx
f010121f:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t * ptep = pgdir_walk(pgdir, va, 0);
f0101222:	83 ec 04             	sub    $0x4,%esp
f0101225:	6a 00                	push   $0x0
f0101227:	ff 75 0c             	pushl  0xc(%ebp)
f010122a:	ff 75 08             	pushl  0x8(%ebp)
f010122d:	e8 5d fe ff ff       	call   f010108f <pgdir_walk>
	if(ptep && ((*ptep) & PTE_P)) {
f0101232:	83 c4 10             	add    $0x10,%esp
f0101235:	85 c0                	test   %eax,%eax
f0101237:	74 46                	je     f010127f <page_lookup+0x70>
f0101239:	89 c1                	mov    %eax,%ecx
f010123b:	8b 10                	mov    (%eax),%edx
f010123d:	f6 c2 01             	test   $0x1,%dl
f0101240:	74 44                	je     f0101286 <page_lookup+0x77>
f0101242:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101245:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f010124b:	39 10                	cmp    %edx,(%eax)
f010124d:	76 18                	jbe    f0101267 <page_lookup+0x58>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010124f:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101255:	8b 00                	mov    (%eax),%eax
f0101257:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		if(pte_store)
f010125a:	85 f6                	test   %esi,%esi
f010125c:	74 02                	je     f0101260 <page_lookup+0x51>
			*pte_store = ptep;
f010125e:	89 0e                	mov    %ecx,(%esi)
}
f0101260:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101263:	5b                   	pop    %ebx
f0101264:	5e                   	pop    %esi
f0101265:	5d                   	pop    %ebp
f0101266:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101267:	83 ec 04             	sub    $0x4,%esp
f010126a:	8d 83 78 d6 fe ff    	lea    -0x12988(%ebx),%eax
f0101270:	50                   	push   %eax
f0101271:	6a 4b                	push   $0x4b
f0101273:	8d 83 75 d1 fe ff    	lea    -0x12e8b(%ebx),%eax
f0101279:	50                   	push   %eax
f010127a:	e8 1a ee ff ff       	call   f0100099 <_panic>
	return NULL;
f010127f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101284:	eb da                	jmp    f0101260 <page_lookup+0x51>
f0101286:	b8 00 00 00 00       	mov    $0x0,%eax
f010128b:	eb d3                	jmp    f0101260 <page_lookup+0x51>

f010128d <page_remove>:
{
f010128d:	55                   	push   %ebp
f010128e:	89 e5                	mov    %esp,%ebp
f0101290:	53                   	push   %ebx
f0101291:	83 ec 18             	sub    $0x18,%esp
f0101294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pp = page_lookup(pgdir, va, &ptep);
f0101297:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010129a:	50                   	push   %eax
f010129b:	53                   	push   %ebx
f010129c:	ff 75 08             	pushl  0x8(%ebp)
f010129f:	e8 6b ff ff ff       	call   f010120f <page_lookup>
	if(!pp || !(*ptep & PTE_P))
f01012a4:	83 c4 10             	add    $0x10,%esp
f01012a7:	85 c0                	test   %eax,%eax
f01012a9:	74 08                	je     f01012b3 <page_remove+0x26>
f01012ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01012ae:	f6 02 01             	testb  $0x1,(%edx)
f01012b1:	75 05                	jne    f01012b8 <page_remove+0x2b>
}
f01012b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012b6:	c9                   	leave  
f01012b7:	c3                   	ret    
	page_decref(pp);		// the ref count of the physical page should decrement
f01012b8:	83 ec 0c             	sub    $0xc,%esp
f01012bb:	50                   	push   %eax
f01012bc:	e8 a5 fd ff ff       	call   f0101066 <page_decref>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01012c1:	0f 01 3b             	invlpg (%ebx)
	*ptep = 0;
f01012c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01012c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f01012cd:	83 c4 10             	add    $0x10,%esp
f01012d0:	eb e1                	jmp    f01012b3 <page_remove+0x26>

f01012d2 <page_insert>:
{
f01012d2:	55                   	push   %ebp
f01012d3:	89 e5                	mov    %esp,%ebp
f01012d5:	57                   	push   %edi
f01012d6:	56                   	push   %esi
f01012d7:	53                   	push   %ebx
f01012d8:	83 ec 10             	sub    $0x10,%esp
f01012db:	e8 de 1c 00 00       	call   f0102fbe <__x86.get_pc_thunk.di>
f01012e0:	81 c7 28 60 01 00    	add    $0x16028,%edi
f01012e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pte_t * ptep = pgdir_walk(pgdir, va, 1);
f01012e9:	6a 01                	push   $0x1
f01012eb:	ff 75 10             	pushl  0x10(%ebp)
f01012ee:	53                   	push   %ebx
f01012ef:	e8 9b fd ff ff       	call   f010108f <pgdir_walk>
	if(ptep == NULL)
f01012f4:	83 c4 10             	add    $0x10,%esp
f01012f7:	85 c0                	test   %eax,%eax
f01012f9:	74 56                	je     f0101351 <page_insert+0x7f>
f01012fb:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f01012fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101300:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	if((*ptep) & PTE_P)
f0101305:	f6 06 01             	testb  $0x1,(%esi)
f0101308:	75 36                	jne    f0101340 <page_insert+0x6e>
	return (pp - pages) << PGSHIFT;
f010130a:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101310:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101313:	2b 08                	sub    (%eax),%ecx
f0101315:	89 c8                	mov    %ecx,%eax
f0101317:	c1 f8 03             	sar    $0x3,%eax
f010131a:	c1 e0 0c             	shl    $0xc,%eax
	*ptep  = page2pa(pp) | PTE_P | perm;
f010131d:	8b 55 14             	mov    0x14(%ebp),%edx
f0101320:	83 ca 01             	or     $0x1,%edx
f0101323:	09 d0                	or     %edx,%eax
f0101325:	89 06                	mov    %eax,(%esi)
	pgdir[PDX(va)] |= perm;
f0101327:	8b 45 10             	mov    0x10(%ebp),%eax
f010132a:	c1 e8 16             	shr    $0x16,%eax
f010132d:	8b 7d 14             	mov    0x14(%ebp),%edi
f0101330:	09 3c 83             	or     %edi,(%ebx,%eax,4)
	return 0;
f0101333:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101338:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010133b:	5b                   	pop    %ebx
f010133c:	5e                   	pop    %esi
f010133d:	5f                   	pop    %edi
f010133e:	5d                   	pop    %ebp
f010133f:	c3                   	ret    
		page_remove(pgdir, va);
f0101340:	83 ec 08             	sub    $0x8,%esp
f0101343:	ff 75 10             	pushl  0x10(%ebp)
f0101346:	53                   	push   %ebx
f0101347:	e8 41 ff ff ff       	call   f010128d <page_remove>
f010134c:	83 c4 10             	add    $0x10,%esp
f010134f:	eb b9                	jmp    f010130a <page_insert+0x38>
		return -E_NO_MEM;
f0101351:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101356:	eb e0                	jmp    f0101338 <page_insert+0x66>

f0101358 <mem_init>:
{
f0101358:	55                   	push   %ebp
f0101359:	89 e5                	mov    %esp,%ebp
f010135b:	57                   	push   %edi
f010135c:	56                   	push   %esi
f010135d:	53                   	push   %ebx
f010135e:	83 ec 48             	sub    $0x48,%esp
f0101361:	e8 e9 ed ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0101366:	81 c3 a2 5f 01 00    	add    $0x15fa2,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010136c:	6a 15                	push   $0x15
f010136e:	e8 4f 1c 00 00       	call   f0102fc2 <mc146818_read>
f0101373:	89 c6                	mov    %eax,%esi
f0101375:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010137c:	e8 41 1c 00 00       	call   f0102fc2 <mc146818_read>
f0101381:	c1 e0 08             	shl    $0x8,%eax
f0101384:	09 f0                	or     %esi,%eax
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101386:	c1 e0 0a             	shl    $0xa,%eax
f0101389:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010138f:	85 c0                	test   %eax,%eax
f0101391:	0f 48 c2             	cmovs  %edx,%eax
f0101394:	c1 f8 0c             	sar    $0xc,%eax
f0101397:	89 83 98 1f 00 00    	mov    %eax,0x1f98(%ebx)
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010139d:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01013a4:	e8 19 1c 00 00       	call   f0102fc2 <mc146818_read>
f01013a9:	89 c6                	mov    %eax,%esi
f01013ab:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01013b2:	e8 0b 1c 00 00       	call   f0102fc2 <mc146818_read>
f01013b7:	c1 e0 08             	shl    $0x8,%eax
f01013ba:	09 f0                	or     %esi,%eax
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01013bc:	c1 e0 0a             	shl    $0xa,%eax
f01013bf:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
f01013c5:	83 c4 10             	add    $0x10,%esp
f01013c8:	85 c0                	test   %eax,%eax
f01013ca:	0f 49 f0             	cmovns %eax,%esi
f01013cd:	c1 fe 0c             	sar    $0xc,%esi
	if (npages_extmem)
f01013d0:	85 f6                	test   %esi,%esi
f01013d2:	0f 85 e1 00 00 00    	jne    f01014b9 <mem_init+0x161>
		npages = npages_basemem;
f01013d8:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01013de:	8b 93 98 1f 00 00    	mov    0x1f98(%ebx),%edx
f01013e4:	89 10                	mov    %edx,(%eax)
		npages_extmem * PGSIZE / 1024);
f01013e6:	89 f0                	mov    %esi,%eax
f01013e8:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013eb:	c1 e8 0a             	shr    $0xa,%eax
f01013ee:	50                   	push   %eax
		npages_basemem * PGSIZE / 1024,
f01013ef:	8b 83 98 1f 00 00    	mov    0x1f98(%ebx),%eax
f01013f5:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013f8:	c1 e8 0a             	shr    $0xa,%eax
f01013fb:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01013fc:	c7 c7 c8 96 11 f0    	mov    $0xf01196c8,%edi
f0101402:	8b 07                	mov    (%edi),%eax
f0101404:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101407:	c1 e8 0a             	shr    $0xa,%eax
f010140a:	50                   	push   %eax
f010140b:	8d 83 98 d6 fe ff    	lea    -0x12968(%ebx),%eax
f0101411:	50                   	push   %eax
f0101412:	e8 32 1c 00 00       	call   f0103049 <cprintf>
	cprintf("npages is %u, npages_basemem is %u, npages_extmem is %u\n", npages, npages_basemem, npages_extmem);
f0101417:	56                   	push   %esi
f0101418:	ff b3 98 1f 00 00    	pushl  0x1f98(%ebx)
f010141e:	ff 37                	pushl  (%edi)
f0101420:	8d 83 d4 d6 fe ff    	lea    -0x1292c(%ebx),%eax
f0101426:	50                   	push   %eax
f0101427:	e8 1d 1c 00 00       	call   f0103049 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010142c:	83 c4 20             	add    $0x20,%esp
f010142f:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101434:	e8 4a f5 ff ff       	call   f0100983 <boot_alloc>
f0101439:	c7 c6 cc 96 11 f0    	mov    $0xf01196cc,%esi
f010143f:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f0101441:	83 ec 04             	sub    $0x4,%esp
f0101444:	68 00 10 00 00       	push   $0x1000
f0101449:	6a 00                	push   $0x0
f010144b:	50                   	push   %eax
f010144c:	e8 54 27 00 00       	call   f0103ba5 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101451:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0101453:	83 c4 10             	add    $0x10,%esp
f0101456:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010145b:	76 6f                	jbe    f01014cc <mem_init+0x174>
	return (physaddr_t)kva - KERNBASE;
f010145d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101463:	83 ca 05             	or     $0x5,%edx
f0101466:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f010146c:	c7 c7 c8 96 11 f0    	mov    $0xf01196c8,%edi
f0101472:	8b 07                	mov    (%edi),%eax
f0101474:	c1 e0 03             	shl    $0x3,%eax
f0101477:	e8 07 f5 ff ff       	call   f0100983 <boot_alloc>
f010147c:	c7 c6 d0 96 11 f0    	mov    $0xf01196d0,%esi
f0101482:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101484:	83 ec 04             	sub    $0x4,%esp
f0101487:	8b 17                	mov    (%edi),%edx
f0101489:	c1 e2 03             	shl    $0x3,%edx
f010148c:	52                   	push   %edx
f010148d:	6a 00                	push   $0x0
f010148f:	50                   	push   %eax
f0101490:	e8 10 27 00 00       	call   f0103ba5 <memset>
	page_init();
f0101495:	e8 ca f9 ff ff       	call   f0100e64 <page_init>
	check_page_free_list(1);
f010149a:	b8 01 00 00 00       	mov    $0x1,%eax
f010149f:	e8 e9 f5 ff ff       	call   f0100a8d <check_page_free_list>
	if (!pages)
f01014a4:	83 c4 10             	add    $0x10,%esp
f01014a7:	83 3e 00             	cmpl   $0x0,(%esi)
f01014aa:	74 39                	je     f01014e5 <mem_init+0x18d>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014ac:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f01014b2:	be 00 00 00 00       	mov    $0x0,%esi
f01014b7:	eb 4c                	jmp    f0101505 <mem_init+0x1ad>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01014b9:	8d 96 00 01 00 00    	lea    0x100(%esi),%edx
f01014bf:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01014c5:	89 10                	mov    %edx,(%eax)
f01014c7:	e9 1a ff ff ff       	jmp    f01013e6 <mem_init+0x8e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014cc:	50                   	push   %eax
f01014cd:	8d 83 10 d7 fe ff    	lea    -0x128f0(%ebx),%eax
f01014d3:	50                   	push   %eax
f01014d4:	68 96 00 00 00       	push   $0x96
f01014d9:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01014df:	50                   	push   %eax
f01014e0:	e8 b4 eb ff ff       	call   f0100099 <_panic>
		panic("'pages' is a null pointer!");
f01014e5:	83 ec 04             	sub    $0x4,%esp
f01014e8:	8d 83 66 d2 fe ff    	lea    -0x12d9a(%ebx),%eax
f01014ee:	50                   	push   %eax
f01014ef:	68 6b 02 00 00       	push   $0x26b
f01014f4:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01014fa:	50                   	push   %eax
f01014fb:	e8 99 eb ff ff       	call   f0100099 <_panic>
		++nfree;
f0101500:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101503:	8b 00                	mov    (%eax),%eax
f0101505:	85 c0                	test   %eax,%eax
f0101507:	75 f7                	jne    f0101500 <mem_init+0x1a8>
	cprintf("should be able to allocate three pages\n");
f0101509:	83 ec 0c             	sub    $0xc,%esp
f010150c:	8d 83 34 d7 fe ff    	lea    -0x128cc(%ebx),%eax
f0101512:	50                   	push   %eax
f0101513:	e8 31 1b 00 00       	call   f0103049 <cprintf>
	assert((pp0 = page_alloc(0)));
f0101518:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010151f:	e8 50 fa ff ff       	call   f0100f74 <page_alloc>
f0101524:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101527:	83 c4 10             	add    $0x10,%esp
f010152a:	85 c0                	test   %eax,%eax
f010152c:	0f 84 7d 02 00 00    	je     f01017af <mem_init+0x457>
	assert((pp1 = page_alloc(0)));
f0101532:	83 ec 0c             	sub    $0xc,%esp
f0101535:	6a 00                	push   $0x0
f0101537:	e8 38 fa ff ff       	call   f0100f74 <page_alloc>
f010153c:	89 c7                	mov    %eax,%edi
f010153e:	83 c4 10             	add    $0x10,%esp
f0101541:	85 c0                	test   %eax,%eax
f0101543:	0f 84 85 02 00 00    	je     f01017ce <mem_init+0x476>
	assert((pp2 = page_alloc(0)));
f0101549:	83 ec 0c             	sub    $0xc,%esp
f010154c:	6a 00                	push   $0x0
f010154e:	e8 21 fa ff ff       	call   f0100f74 <page_alloc>
f0101553:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101556:	83 c4 10             	add    $0x10,%esp
f0101559:	85 c0                	test   %eax,%eax
f010155b:	0f 84 8c 02 00 00    	je     f01017ed <mem_init+0x495>
	assert(pp1 && pp1 != pp0);
f0101561:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0101564:	0f 84 a2 02 00 00    	je     f010180c <mem_init+0x4b4>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010156a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010156d:	39 c7                	cmp    %eax,%edi
f010156f:	0f 84 b6 02 00 00    	je     f010182b <mem_init+0x4d3>
f0101575:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101578:	0f 84 ad 02 00 00    	je     f010182b <mem_init+0x4d3>
	return (pp - pages) << PGSHIFT;
f010157e:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101584:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101586:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f010158c:	8b 10                	mov    (%eax),%edx
f010158e:	c1 e2 0c             	shl    $0xc,%edx
f0101591:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101594:	29 c8                	sub    %ecx,%eax
f0101596:	c1 f8 03             	sar    $0x3,%eax
f0101599:	c1 e0 0c             	shl    $0xc,%eax
f010159c:	39 d0                	cmp    %edx,%eax
f010159e:	0f 83 a6 02 00 00    	jae    f010184a <mem_init+0x4f2>
f01015a4:	89 f8                	mov    %edi,%eax
f01015a6:	29 c8                	sub    %ecx,%eax
f01015a8:	c1 f8 03             	sar    $0x3,%eax
f01015ab:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01015ae:	39 c2                	cmp    %eax,%edx
f01015b0:	0f 86 b3 02 00 00    	jbe    f0101869 <mem_init+0x511>
f01015b6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015b9:	29 c8                	sub    %ecx,%eax
f01015bb:	c1 f8 03             	sar    $0x3,%eax
f01015be:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01015c1:	39 c2                	cmp    %eax,%edx
f01015c3:	0f 86 bf 02 00 00    	jbe    f0101888 <mem_init+0x530>
	fl = page_free_list;
f01015c9:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f01015cf:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01015d2:	c7 83 94 1f 00 00 00 	movl   $0x0,0x1f94(%ebx)
f01015d9:	00 00 00 
	assert(!page_alloc(0));
f01015dc:	83 ec 0c             	sub    $0xc,%esp
f01015df:	6a 00                	push   $0x0
f01015e1:	e8 8e f9 ff ff       	call   f0100f74 <page_alloc>
f01015e6:	83 c4 10             	add    $0x10,%esp
f01015e9:	85 c0                	test   %eax,%eax
f01015eb:	0f 85 b6 02 00 00    	jne    f01018a7 <mem_init+0x54f>
	page_free(pp0);
f01015f1:	83 ec 0c             	sub    $0xc,%esp
f01015f4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015f7:	e8 00 fa ff ff       	call   f0100ffc <page_free>
	page_free(pp1);
f01015fc:	89 3c 24             	mov    %edi,(%esp)
f01015ff:	e8 f8 f9 ff ff       	call   f0100ffc <page_free>
	page_free(pp2);
f0101604:	83 c4 04             	add    $0x4,%esp
f0101607:	ff 75 d0             	pushl  -0x30(%ebp)
f010160a:	e8 ed f9 ff ff       	call   f0100ffc <page_free>
	assert((pp0 = page_alloc(0)));
f010160f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101616:	e8 59 f9 ff ff       	call   f0100f74 <page_alloc>
f010161b:	89 c7                	mov    %eax,%edi
f010161d:	83 c4 10             	add    $0x10,%esp
f0101620:	85 c0                	test   %eax,%eax
f0101622:	0f 84 9e 02 00 00    	je     f01018c6 <mem_init+0x56e>
	assert((pp1 = page_alloc(0)));
f0101628:	83 ec 0c             	sub    $0xc,%esp
f010162b:	6a 00                	push   $0x0
f010162d:	e8 42 f9 ff ff       	call   f0100f74 <page_alloc>
f0101632:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101635:	83 c4 10             	add    $0x10,%esp
f0101638:	85 c0                	test   %eax,%eax
f010163a:	0f 84 a5 02 00 00    	je     f01018e5 <mem_init+0x58d>
	assert((pp2 = page_alloc(0)));
f0101640:	83 ec 0c             	sub    $0xc,%esp
f0101643:	6a 00                	push   $0x0
f0101645:	e8 2a f9 ff ff       	call   f0100f74 <page_alloc>
f010164a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010164d:	83 c4 10             	add    $0x10,%esp
f0101650:	85 c0                	test   %eax,%eax
f0101652:	0f 84 ac 02 00 00    	je     f0101904 <mem_init+0x5ac>
	assert(pp1 && pp1 != pp0);
f0101658:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010165b:	0f 84 c2 02 00 00    	je     f0101923 <mem_init+0x5cb>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101661:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101664:	39 c7                	cmp    %eax,%edi
f0101666:	0f 84 d6 02 00 00    	je     f0101942 <mem_init+0x5ea>
f010166c:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010166f:	0f 84 cd 02 00 00    	je     f0101942 <mem_init+0x5ea>
	assert(!page_alloc(0));
f0101675:	83 ec 0c             	sub    $0xc,%esp
f0101678:	6a 00                	push   $0x0
f010167a:	e8 f5 f8 ff ff       	call   f0100f74 <page_alloc>
f010167f:	83 c4 10             	add    $0x10,%esp
f0101682:	85 c0                	test   %eax,%eax
f0101684:	0f 85 d7 02 00 00    	jne    f0101961 <mem_init+0x609>
	cprintf("test flags\n");
f010168a:	83 ec 0c             	sub    $0xc,%esp
f010168d:	8d 83 3b d3 fe ff    	lea    -0x12cc5(%ebx),%eax
f0101693:	50                   	push   %eax
f0101694:	e8 b0 19 00 00       	call   f0103049 <cprintf>
f0101699:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f010169f:	89 f9                	mov    %edi,%ecx
f01016a1:	2b 08                	sub    (%eax),%ecx
f01016a3:	89 c8                	mov    %ecx,%eax
f01016a5:	c1 f8 03             	sar    $0x3,%eax
f01016a8:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01016ab:	89 c1                	mov    %eax,%ecx
f01016ad:	c1 e9 0c             	shr    $0xc,%ecx
f01016b0:	83 c4 10             	add    $0x10,%esp
f01016b3:	c7 c2 c8 96 11 f0    	mov    $0xf01196c8,%edx
f01016b9:	3b 0a                	cmp    (%edx),%ecx
f01016bb:	0f 83 bf 02 00 00    	jae    f0101980 <mem_init+0x628>
	cprintf("page2kva(pp0) is %x\n", page2kva(pp0));
f01016c1:	83 ec 08             	sub    $0x8,%esp
	return (void *)(pa + KERNBASE);
f01016c4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016c9:	50                   	push   %eax
f01016ca:	8d 83 47 d3 fe ff    	lea    -0x12cb9(%ebx),%eax
f01016d0:	50                   	push   %eax
f01016d1:	e8 73 19 00 00       	call   f0103049 <cprintf>
	return (pp - pages) << PGSHIFT;
f01016d6:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f01016dc:	89 f9                	mov    %edi,%ecx
f01016de:	2b 08                	sub    (%eax),%ecx
f01016e0:	89 c8                	mov    %ecx,%eax
f01016e2:	c1 f8 03             	sar    $0x3,%eax
f01016e5:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01016e8:	89 c1                	mov    %eax,%ecx
f01016ea:	c1 e9 0c             	shr    $0xc,%ecx
f01016ed:	83 c4 10             	add    $0x10,%esp
f01016f0:	c7 c2 c8 96 11 f0    	mov    $0xf01196c8,%edx
f01016f6:	3b 0a                	cmp    (%edx),%ecx
f01016f8:	0f 83 98 02 00 00    	jae    f0101996 <mem_init+0x63e>
	memset(page2kva(pp0), 1, PGSIZE);
f01016fe:	83 ec 04             	sub    $0x4,%esp
f0101701:	68 00 10 00 00       	push   $0x1000
f0101706:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101708:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010170d:	50                   	push   %eax
f010170e:	e8 92 24 00 00       	call   f0103ba5 <memset>
	page_free(pp0);
f0101713:	89 3c 24             	mov    %edi,(%esp)
f0101716:	e8 e1 f8 ff ff       	call   f0100ffc <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010171b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101722:	e8 4d f8 ff ff       	call   f0100f74 <page_alloc>
f0101727:	83 c4 10             	add    $0x10,%esp
f010172a:	85 c0                	test   %eax,%eax
f010172c:	0f 84 7a 02 00 00    	je     f01019ac <mem_init+0x654>
	assert(pp && pp0 == pp);
f0101732:	39 c7                	cmp    %eax,%edi
f0101734:	0f 85 91 02 00 00    	jne    f01019cb <mem_init+0x673>
	return (pp - pages) << PGSHIFT;
f010173a:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101740:	89 fa                	mov    %edi,%edx
f0101742:	2b 10                	sub    (%eax),%edx
f0101744:	c1 fa 03             	sar    $0x3,%edx
f0101747:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010174a:	89 d1                	mov    %edx,%ecx
f010174c:	c1 e9 0c             	shr    $0xc,%ecx
f010174f:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0101755:	3b 08                	cmp    (%eax),%ecx
f0101757:	0f 83 8d 02 00 00    	jae    f01019ea <mem_init+0x692>
	return (void *)(pa + KERNBASE);
f010175d:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101763:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101769:	80 38 00             	cmpb   $0x0,(%eax)
f010176c:	0f 85 8e 02 00 00    	jne    f0101a00 <mem_init+0x6a8>
f0101772:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101775:	39 c2                	cmp    %eax,%edx
f0101777:	75 f0                	jne    f0101769 <mem_init+0x411>
	page_free_list = fl;
f0101779:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010177c:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
	page_free(pp0);
f0101782:	83 ec 0c             	sub    $0xc,%esp
f0101785:	57                   	push   %edi
f0101786:	e8 71 f8 ff ff       	call   f0100ffc <page_free>
	page_free(pp1);
f010178b:	83 c4 04             	add    $0x4,%esp
f010178e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101791:	e8 66 f8 ff ff       	call   f0100ffc <page_free>
	page_free(pp2);
f0101796:	83 c4 04             	add    $0x4,%esp
f0101799:	ff 75 d0             	pushl  -0x30(%ebp)
f010179c:	e8 5b f8 ff ff       	call   f0100ffc <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017a1:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f01017a7:	83 c4 10             	add    $0x10,%esp
f01017aa:	e9 75 02 00 00       	jmp    f0101a24 <mem_init+0x6cc>
	assert((pp0 = page_alloc(0)));
f01017af:	8d 83 81 d2 fe ff    	lea    -0x12d7f(%ebx),%eax
f01017b5:	50                   	push   %eax
f01017b6:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01017bc:	50                   	push   %eax
f01017bd:	68 74 02 00 00       	push   $0x274
f01017c2:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01017c8:	50                   	push   %eax
f01017c9:	e8 cb e8 ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f01017ce:	8d 83 97 d2 fe ff    	lea    -0x12d69(%ebx),%eax
f01017d4:	50                   	push   %eax
f01017d5:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01017db:	50                   	push   %eax
f01017dc:	68 75 02 00 00       	push   $0x275
f01017e1:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01017e7:	50                   	push   %eax
f01017e8:	e8 ac e8 ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f01017ed:	8d 83 ad d2 fe ff    	lea    -0x12d53(%ebx),%eax
f01017f3:	50                   	push   %eax
f01017f4:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01017fa:	50                   	push   %eax
f01017fb:	68 76 02 00 00       	push   $0x276
f0101800:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0101806:	50                   	push   %eax
f0101807:	e8 8d e8 ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f010180c:	8d 83 c3 d2 fe ff    	lea    -0x12d3d(%ebx),%eax
f0101812:	50                   	push   %eax
f0101813:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0101819:	50                   	push   %eax
f010181a:	68 7c 02 00 00       	push   $0x27c
f010181f:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0101825:	50                   	push   %eax
f0101826:	e8 6e e8 ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010182b:	8d 83 5c d7 fe ff    	lea    -0x128a4(%ebx),%eax
f0101831:	50                   	push   %eax
f0101832:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0101838:	50                   	push   %eax
f0101839:	68 7d 02 00 00       	push   $0x27d
f010183e:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0101844:	50                   	push   %eax
f0101845:	e8 4f e8 ff ff       	call   f0100099 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010184a:	8d 83 d5 d2 fe ff    	lea    -0x12d2b(%ebx),%eax
f0101850:	50                   	push   %eax
f0101851:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0101857:	50                   	push   %eax
f0101858:	68 7e 02 00 00       	push   $0x27e
f010185d:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0101863:	50                   	push   %eax
f0101864:	e8 30 e8 ff ff       	call   f0100099 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101869:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010186f:	50                   	push   %eax
f0101870:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0101876:	50                   	push   %eax
f0101877:	68 7f 02 00 00       	push   $0x27f
f010187c:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0101882:	50                   	push   %eax
f0101883:	e8 11 e8 ff ff       	call   f0100099 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101888:	8d 83 0f d3 fe ff    	lea    -0x12cf1(%ebx),%eax
f010188e:	50                   	push   %eax
f010188f:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0101895:	50                   	push   %eax
f0101896:	68 80 02 00 00       	push   $0x280
f010189b:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01018a1:	50                   	push   %eax
f01018a2:	e8 f2 e7 ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f01018a7:	8d 83 2c d3 fe ff    	lea    -0x12cd4(%ebx),%eax
f01018ad:	50                   	push   %eax
f01018ae:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01018b4:	50                   	push   %eax
f01018b5:	68 87 02 00 00       	push   $0x287
f01018ba:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01018c0:	50                   	push   %eax
f01018c1:	e8 d3 e7 ff ff       	call   f0100099 <_panic>
	assert((pp0 = page_alloc(0)));
f01018c6:	8d 83 81 d2 fe ff    	lea    -0x12d7f(%ebx),%eax
f01018cc:	50                   	push   %eax
f01018cd:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01018d3:	50                   	push   %eax
f01018d4:	68 8e 02 00 00       	push   $0x28e
f01018d9:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01018df:	50                   	push   %eax
f01018e0:	e8 b4 e7 ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f01018e5:	8d 83 97 d2 fe ff    	lea    -0x12d69(%ebx),%eax
f01018eb:	50                   	push   %eax
f01018ec:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01018f2:	50                   	push   %eax
f01018f3:	68 8f 02 00 00       	push   $0x28f
f01018f8:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01018fe:	50                   	push   %eax
f01018ff:	e8 95 e7 ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f0101904:	8d 83 ad d2 fe ff    	lea    -0x12d53(%ebx),%eax
f010190a:	50                   	push   %eax
f010190b:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0101911:	50                   	push   %eax
f0101912:	68 90 02 00 00       	push   $0x290
f0101917:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010191d:	50                   	push   %eax
f010191e:	e8 76 e7 ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f0101923:	8d 83 c3 d2 fe ff    	lea    -0x12d3d(%ebx),%eax
f0101929:	50                   	push   %eax
f010192a:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0101930:	50                   	push   %eax
f0101931:	68 92 02 00 00       	push   $0x292
f0101936:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010193c:	50                   	push   %eax
f010193d:	e8 57 e7 ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101942:	8d 83 5c d7 fe ff    	lea    -0x128a4(%ebx),%eax
f0101948:	50                   	push   %eax
f0101949:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010194f:	50                   	push   %eax
f0101950:	68 93 02 00 00       	push   $0x293
f0101955:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010195b:	50                   	push   %eax
f010195c:	e8 38 e7 ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0101961:	8d 83 2c d3 fe ff    	lea    -0x12cd4(%ebx),%eax
f0101967:	50                   	push   %eax
f0101968:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010196e:	50                   	push   %eax
f010196f:	68 94 02 00 00       	push   $0x294
f0101974:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010197a:	50                   	push   %eax
f010197b:	e8 19 e7 ff ff       	call   f0100099 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101980:	50                   	push   %eax
f0101981:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f0101987:	50                   	push   %eax
f0101988:	6a 52                	push   $0x52
f010198a:	8d 83 75 d1 fe ff    	lea    -0x12e8b(%ebx),%eax
f0101990:	50                   	push   %eax
f0101991:	e8 03 e7 ff ff       	call   f0100099 <_panic>
f0101996:	50                   	push   %eax
f0101997:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f010199d:	50                   	push   %eax
f010199e:	6a 52                	push   $0x52
f01019a0:	8d 83 75 d1 fe ff    	lea    -0x12e8b(%ebx),%eax
f01019a6:	50                   	push   %eax
f01019a7:	e8 ed e6 ff ff       	call   f0100099 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01019ac:	8d 83 5c d3 fe ff    	lea    -0x12ca4(%ebx),%eax
f01019b2:	50                   	push   %eax
f01019b3:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01019b9:	50                   	push   %eax
f01019ba:	68 9b 02 00 00       	push   $0x29b
f01019bf:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01019c5:	50                   	push   %eax
f01019c6:	e8 ce e6 ff ff       	call   f0100099 <_panic>
	assert(pp && pp0 == pp);
f01019cb:	8d 83 7a d3 fe ff    	lea    -0x12c86(%ebx),%eax
f01019d1:	50                   	push   %eax
f01019d2:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01019d8:	50                   	push   %eax
f01019d9:	68 9c 02 00 00       	push   $0x29c
f01019de:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01019e4:	50                   	push   %eax
f01019e5:	e8 af e6 ff ff       	call   f0100099 <_panic>
f01019ea:	52                   	push   %edx
f01019eb:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f01019f1:	50                   	push   %eax
f01019f2:	6a 52                	push   $0x52
f01019f4:	8d 83 75 d1 fe ff    	lea    -0x12e8b(%ebx),%eax
f01019fa:	50                   	push   %eax
f01019fb:	e8 99 e6 ff ff       	call   f0100099 <_panic>
		assert(c[i] == 0);
f0101a00:	8d 83 8a d3 fe ff    	lea    -0x12c76(%ebx),%eax
f0101a06:	50                   	push   %eax
f0101a07:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0101a0d:	50                   	push   %eax
f0101a0e:	68 9f 02 00 00       	push   $0x29f
f0101a13:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0101a19:	50                   	push   %eax
f0101a1a:	e8 7a e6 ff ff       	call   f0100099 <_panic>
		--nfree;
f0101a1f:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a22:	8b 00                	mov    (%eax),%eax
f0101a24:	85 c0                	test   %eax,%eax
f0101a26:	75 f7                	jne    f0101a1f <mem_init+0x6c7>
	assert(nfree == 0);
f0101a28:	85 f6                	test   %esi,%esi
f0101a2a:	0f 85 36 08 00 00    	jne    f0102266 <mem_init+0xf0e>
	cprintf("check_page_alloc() succeeded!\n");
f0101a30:	83 ec 0c             	sub    $0xc,%esp
f0101a33:	8d 83 7c d7 fe ff    	lea    -0x12884(%ebx),%eax
f0101a39:	50                   	push   %eax
f0101a3a:	e8 0a 16 00 00       	call   f0103049 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a46:	e8 29 f5 ff ff       	call   f0100f74 <page_alloc>
f0101a4b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a4e:	83 c4 10             	add    $0x10,%esp
f0101a51:	85 c0                	test   %eax,%eax
f0101a53:	0f 84 2c 08 00 00    	je     f0102285 <mem_init+0xf2d>
	assert((pp1 = page_alloc(0)));
f0101a59:	83 ec 0c             	sub    $0xc,%esp
f0101a5c:	6a 00                	push   $0x0
f0101a5e:	e8 11 f5 ff ff       	call   f0100f74 <page_alloc>
f0101a63:	89 c7                	mov    %eax,%edi
f0101a65:	83 c4 10             	add    $0x10,%esp
f0101a68:	85 c0                	test   %eax,%eax
f0101a6a:	0f 84 34 08 00 00    	je     f01022a4 <mem_init+0xf4c>
	assert((pp2 = page_alloc(0)));
f0101a70:	83 ec 0c             	sub    $0xc,%esp
f0101a73:	6a 00                	push   $0x0
f0101a75:	e8 fa f4 ff ff       	call   f0100f74 <page_alloc>
f0101a7a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a7d:	83 c4 10             	add    $0x10,%esp
f0101a80:	85 c0                	test   %eax,%eax
f0101a82:	0f 84 3b 08 00 00    	je     f01022c3 <mem_init+0xf6b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a88:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101a8b:	0f 84 51 08 00 00    	je     f01022e2 <mem_init+0xf8a>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a94:	39 c7                	cmp    %eax,%edi
f0101a96:	0f 84 65 08 00 00    	je     f0102301 <mem_init+0xfa9>
f0101a9c:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101a9f:	0f 84 5c 08 00 00    	je     f0102301 <mem_init+0xfa9>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101aa5:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f0101aab:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	page_free_list = 0;
f0101aae:	c7 83 94 1f 00 00 00 	movl   $0x0,0x1f94(%ebx)
f0101ab5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ab8:	83 ec 0c             	sub    $0xc,%esp
f0101abb:	6a 00                	push   $0x0
f0101abd:	e8 b2 f4 ff ff       	call   f0100f74 <page_alloc>
f0101ac2:	83 c4 10             	add    $0x10,%esp
f0101ac5:	85 c0                	test   %eax,%eax
f0101ac7:	0f 85 53 08 00 00    	jne    f0102320 <mem_init+0xfc8>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101acd:	83 ec 04             	sub    $0x4,%esp
f0101ad0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ad3:	50                   	push   %eax
f0101ad4:	6a 00                	push   $0x0
f0101ad6:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101adc:	ff 30                	pushl  (%eax)
f0101ade:	e8 2c f7 ff ff       	call   f010120f <page_lookup>
f0101ae3:	83 c4 10             	add    $0x10,%esp
f0101ae6:	85 c0                	test   %eax,%eax
f0101ae8:	0f 85 51 08 00 00    	jne    f010233f <mem_init+0xfe7>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101aee:	6a 02                	push   $0x2
f0101af0:	6a 00                	push   $0x0
f0101af2:	57                   	push   %edi
f0101af3:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101af9:	ff 30                	pushl  (%eax)
f0101afb:	e8 d2 f7 ff ff       	call   f01012d2 <page_insert>
f0101b00:	83 c4 10             	add    $0x10,%esp
f0101b03:	85 c0                	test   %eax,%eax
f0101b05:	0f 89 53 08 00 00    	jns    f010235e <mem_init+0x1006>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b0b:	83 ec 0c             	sub    $0xc,%esp
f0101b0e:	ff 75 d0             	pushl  -0x30(%ebp)
f0101b11:	e8 e6 f4 ff ff       	call   f0100ffc <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b16:	6a 02                	push   $0x2
f0101b18:	6a 00                	push   $0x0
f0101b1a:	57                   	push   %edi
f0101b1b:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101b21:	ff 30                	pushl  (%eax)
f0101b23:	e8 aa f7 ff ff       	call   f01012d2 <page_insert>
f0101b28:	83 c4 20             	add    $0x20,%esp
f0101b2b:	85 c0                	test   %eax,%eax
f0101b2d:	0f 85 4a 08 00 00    	jne    f010237d <mem_init+0x1025>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b33:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101b39:	8b 08                	mov    (%eax),%ecx
f0101b3b:	89 ce                	mov    %ecx,%esi
	return (pp - pages) << PGSHIFT;
f0101b3d:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101b43:	8b 00                	mov    (%eax),%eax
f0101b45:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b48:	8b 09                	mov    (%ecx),%ecx
f0101b4a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101b4d:	89 ca                	mov    %ecx,%edx
f0101b4f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b55:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101b58:	29 c1                	sub    %eax,%ecx
f0101b5a:	89 c8                	mov    %ecx,%eax
f0101b5c:	c1 f8 03             	sar    $0x3,%eax
f0101b5f:	c1 e0 0c             	shl    $0xc,%eax
f0101b62:	39 c2                	cmp    %eax,%edx
f0101b64:	0f 85 32 08 00 00    	jne    f010239c <mem_init+0x1044>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b6a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b6f:	89 f0                	mov    %esi,%eax
f0101b71:	e8 9a ee ff ff       	call   f0100a10 <check_va2pa>
f0101b76:	89 fa                	mov    %edi,%edx
f0101b78:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b7b:	c1 fa 03             	sar    $0x3,%edx
f0101b7e:	c1 e2 0c             	shl    $0xc,%edx
f0101b81:	39 d0                	cmp    %edx,%eax
f0101b83:	0f 85 32 08 00 00    	jne    f01023bb <mem_init+0x1063>
	assert(pp1->pp_ref == 1);
f0101b89:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b8e:	0f 85 46 08 00 00    	jne    f01023da <mem_init+0x1082>
	assert(pp0->pp_ref == 1);
f0101b94:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b97:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b9c:	0f 85 57 08 00 00    	jne    f01023f9 <mem_init+0x10a1>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ba2:	6a 02                	push   $0x2
f0101ba4:	68 00 10 00 00       	push   $0x1000
f0101ba9:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bac:	56                   	push   %esi
f0101bad:	e8 20 f7 ff ff       	call   f01012d2 <page_insert>
f0101bb2:	83 c4 10             	add    $0x10,%esp
f0101bb5:	85 c0                	test   %eax,%eax
f0101bb7:	0f 85 5b 08 00 00    	jne    f0102418 <mem_init+0x10c0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bbd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bc2:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101bc8:	8b 00                	mov    (%eax),%eax
f0101bca:	e8 41 ee ff ff       	call   f0100a10 <check_va2pa>
f0101bcf:	c7 c2 d0 96 11 f0    	mov    $0xf01196d0,%edx
f0101bd5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101bd8:	2b 0a                	sub    (%edx),%ecx
f0101bda:	89 ca                	mov    %ecx,%edx
f0101bdc:	c1 fa 03             	sar    $0x3,%edx
f0101bdf:	c1 e2 0c             	shl    $0xc,%edx
f0101be2:	39 d0                	cmp    %edx,%eax
f0101be4:	0f 85 4d 08 00 00    	jne    f0102437 <mem_init+0x10df>
	assert(pp2->pp_ref == 1);
f0101bea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bed:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bf2:	0f 85 5e 08 00 00    	jne    f0102456 <mem_init+0x10fe>

	// should be no free memory
	assert(!page_alloc(0));
f0101bf8:	83 ec 0c             	sub    $0xc,%esp
f0101bfb:	6a 00                	push   $0x0
f0101bfd:	e8 72 f3 ff ff       	call   f0100f74 <page_alloc>
f0101c02:	83 c4 10             	add    $0x10,%esp
f0101c05:	85 c0                	test   %eax,%eax
f0101c07:	0f 85 68 08 00 00    	jne    f0102475 <mem_init+0x111d>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c0d:	6a 02                	push   $0x2
f0101c0f:	68 00 10 00 00       	push   $0x1000
f0101c14:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c17:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101c1d:	ff 30                	pushl  (%eax)
f0101c1f:	e8 ae f6 ff ff       	call   f01012d2 <page_insert>
f0101c24:	83 c4 10             	add    $0x10,%esp
f0101c27:	85 c0                	test   %eax,%eax
f0101c29:	0f 85 65 08 00 00    	jne    f0102494 <mem_init+0x113c>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c2f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c34:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101c3a:	8b 00                	mov    (%eax),%eax
f0101c3c:	e8 cf ed ff ff       	call   f0100a10 <check_va2pa>
f0101c41:	c7 c2 d0 96 11 f0    	mov    $0xf01196d0,%edx
f0101c47:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101c4a:	2b 0a                	sub    (%edx),%ecx
f0101c4c:	89 ca                	mov    %ecx,%edx
f0101c4e:	c1 fa 03             	sar    $0x3,%edx
f0101c51:	c1 e2 0c             	shl    $0xc,%edx
f0101c54:	39 d0                	cmp    %edx,%eax
f0101c56:	0f 85 57 08 00 00    	jne    f01024b3 <mem_init+0x115b>
	assert(pp2->pp_ref == 1);
f0101c5c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c5f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c64:	0f 85 68 08 00 00    	jne    f01024d2 <mem_init+0x117a>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c6a:	83 ec 0c             	sub    $0xc,%esp
f0101c6d:	6a 00                	push   $0x0
f0101c6f:	e8 00 f3 ff ff       	call   f0100f74 <page_alloc>
f0101c74:	83 c4 10             	add    $0x10,%esp
f0101c77:	85 c0                	test   %eax,%eax
f0101c79:	0f 85 72 08 00 00    	jne    f01024f1 <mem_init+0x1199>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c7f:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101c85:	8b 10                	mov    (%eax),%edx
f0101c87:	8b 02                	mov    (%edx),%eax
f0101c89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101c8e:	89 c1                	mov    %eax,%ecx
f0101c90:	c1 e9 0c             	shr    $0xc,%ecx
f0101c93:	89 ce                	mov    %ecx,%esi
f0101c95:	c7 c1 c8 96 11 f0    	mov    $0xf01196c8,%ecx
f0101c9b:	3b 31                	cmp    (%ecx),%esi
f0101c9d:	0f 83 6d 08 00 00    	jae    f0102510 <mem_init+0x11b8>
	return (void *)(pa + KERNBASE);
f0101ca3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ca8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101cab:	83 ec 04             	sub    $0x4,%esp
f0101cae:	6a 00                	push   $0x0
f0101cb0:	68 00 10 00 00       	push   $0x1000
f0101cb5:	52                   	push   %edx
f0101cb6:	e8 d4 f3 ff ff       	call   f010108f <pgdir_walk>
f0101cbb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101cbe:	8d 51 04             	lea    0x4(%ecx),%edx
f0101cc1:	83 c4 10             	add    $0x10,%esp
f0101cc4:	39 d0                	cmp    %edx,%eax
f0101cc6:	0f 85 5d 08 00 00    	jne    f0102529 <mem_init+0x11d1>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ccc:	6a 06                	push   $0x6
f0101cce:	68 00 10 00 00       	push   $0x1000
f0101cd3:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101cd6:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101cdc:	ff 30                	pushl  (%eax)
f0101cde:	e8 ef f5 ff ff       	call   f01012d2 <page_insert>
f0101ce3:	83 c4 10             	add    $0x10,%esp
f0101ce6:	85 c0                	test   %eax,%eax
f0101ce8:	0f 85 5a 08 00 00    	jne    f0102548 <mem_init+0x11f0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cee:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101cf4:	8b 00                	mov    (%eax),%eax
f0101cf6:	89 c6                	mov    %eax,%esi
f0101cf8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cfd:	e8 0e ed ff ff       	call   f0100a10 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101d02:	c7 c2 d0 96 11 f0    	mov    $0xf01196d0,%edx
f0101d08:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d0b:	2b 0a                	sub    (%edx),%ecx
f0101d0d:	89 ca                	mov    %ecx,%edx
f0101d0f:	c1 fa 03             	sar    $0x3,%edx
f0101d12:	c1 e2 0c             	shl    $0xc,%edx
f0101d15:	39 d0                	cmp    %edx,%eax
f0101d17:	0f 85 4a 08 00 00    	jne    f0102567 <mem_init+0x120f>
	assert(pp2->pp_ref == 1);
f0101d1d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d20:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d25:	0f 85 5b 08 00 00    	jne    f0102586 <mem_init+0x122e>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d2b:	83 ec 04             	sub    $0x4,%esp
f0101d2e:	6a 00                	push   $0x0
f0101d30:	68 00 10 00 00       	push   $0x1000
f0101d35:	56                   	push   %esi
f0101d36:	e8 54 f3 ff ff       	call   f010108f <pgdir_walk>
f0101d3b:	83 c4 10             	add    $0x10,%esp
f0101d3e:	f6 00 04             	testb  $0x4,(%eax)
f0101d41:	0f 84 5e 08 00 00    	je     f01025a5 <mem_init+0x124d>
	assert(kern_pgdir[0] & PTE_U);
f0101d47:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101d4d:	8b 00                	mov    (%eax),%eax
f0101d4f:	f6 00 04             	testb  $0x4,(%eax)
f0101d52:	0f 84 6c 08 00 00    	je     f01025c4 <mem_init+0x126c>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d58:	6a 02                	push   $0x2
f0101d5a:	68 00 10 00 00       	push   $0x1000
f0101d5f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d62:	50                   	push   %eax
f0101d63:	e8 6a f5 ff ff       	call   f01012d2 <page_insert>
f0101d68:	83 c4 10             	add    $0x10,%esp
f0101d6b:	85 c0                	test   %eax,%eax
f0101d6d:	0f 85 70 08 00 00    	jne    f01025e3 <mem_init+0x128b>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d73:	83 ec 04             	sub    $0x4,%esp
f0101d76:	6a 00                	push   $0x0
f0101d78:	68 00 10 00 00       	push   $0x1000
f0101d7d:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101d83:	ff 30                	pushl  (%eax)
f0101d85:	e8 05 f3 ff ff       	call   f010108f <pgdir_walk>
f0101d8a:	83 c4 10             	add    $0x10,%esp
f0101d8d:	f6 00 02             	testb  $0x2,(%eax)
f0101d90:	0f 84 6c 08 00 00    	je     f0102602 <mem_init+0x12aa>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d96:	83 ec 04             	sub    $0x4,%esp
f0101d99:	6a 00                	push   $0x0
f0101d9b:	68 00 10 00 00       	push   $0x1000
f0101da0:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101da6:	ff 30                	pushl  (%eax)
f0101da8:	e8 e2 f2 ff ff       	call   f010108f <pgdir_walk>
f0101dad:	83 c4 10             	add    $0x10,%esp
f0101db0:	f6 00 04             	testb  $0x4,(%eax)
f0101db3:	0f 85 68 08 00 00    	jne    f0102621 <mem_init+0x12c9>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101db9:	6a 02                	push   $0x2
f0101dbb:	68 00 00 40 00       	push   $0x400000
f0101dc0:	ff 75 d0             	pushl  -0x30(%ebp)
f0101dc3:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101dc9:	ff 30                	pushl  (%eax)
f0101dcb:	e8 02 f5 ff ff       	call   f01012d2 <page_insert>
f0101dd0:	83 c4 10             	add    $0x10,%esp
f0101dd3:	85 c0                	test   %eax,%eax
f0101dd5:	0f 89 65 08 00 00    	jns    f0102640 <mem_init+0x12e8>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101ddb:	6a 02                	push   $0x2
f0101ddd:	68 00 10 00 00       	push   $0x1000
f0101de2:	57                   	push   %edi
f0101de3:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101de9:	ff 30                	pushl  (%eax)
f0101deb:	e8 e2 f4 ff ff       	call   f01012d2 <page_insert>
f0101df0:	83 c4 10             	add    $0x10,%esp
f0101df3:	85 c0                	test   %eax,%eax
f0101df5:	0f 85 64 08 00 00    	jne    f010265f <mem_init+0x1307>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101dfb:	83 ec 04             	sub    $0x4,%esp
f0101dfe:	6a 00                	push   $0x0
f0101e00:	68 00 10 00 00       	push   $0x1000
f0101e05:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101e0b:	ff 30                	pushl  (%eax)
f0101e0d:	e8 7d f2 ff ff       	call   f010108f <pgdir_walk>
f0101e12:	83 c4 10             	add    $0x10,%esp
f0101e15:	f6 00 04             	testb  $0x4,(%eax)
f0101e18:	0f 85 60 08 00 00    	jne    f010267e <mem_init+0x1326>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e1e:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101e24:	8b 00                	mov    (%eax),%eax
f0101e26:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e29:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e2e:	e8 dd eb ff ff       	call   f0100a10 <check_va2pa>
f0101e33:	89 c6                	mov    %eax,%esi
f0101e35:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101e3b:	89 f9                	mov    %edi,%ecx
f0101e3d:	2b 08                	sub    (%eax),%ecx
f0101e3f:	89 c8                	mov    %ecx,%eax
f0101e41:	c1 f8 03             	sar    $0x3,%eax
f0101e44:	c1 e0 0c             	shl    $0xc,%eax
f0101e47:	39 c6                	cmp    %eax,%esi
f0101e49:	0f 85 4e 08 00 00    	jne    f010269d <mem_init+0x1345>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e4f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e54:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101e57:	e8 b4 eb ff ff       	call   f0100a10 <check_va2pa>
f0101e5c:	39 c6                	cmp    %eax,%esi
f0101e5e:	0f 85 58 08 00 00    	jne    f01026bc <mem_init+0x1364>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e64:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101e69:	0f 85 6c 08 00 00    	jne    f01026db <mem_init+0x1383>
	assert(pp2->pp_ref == 0);
f0101e6f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e72:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e77:	0f 85 7d 08 00 00    	jne    f01026fa <mem_init+0x13a2>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e7d:	83 ec 0c             	sub    $0xc,%esp
f0101e80:	6a 00                	push   $0x0
f0101e82:	e8 ed f0 ff ff       	call   f0100f74 <page_alloc>
f0101e87:	83 c4 10             	add    $0x10,%esp
f0101e8a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101e8d:	0f 85 86 08 00 00    	jne    f0102719 <mem_init+0x13c1>
f0101e93:	85 c0                	test   %eax,%eax
f0101e95:	0f 84 7e 08 00 00    	je     f0102719 <mem_init+0x13c1>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e9b:	83 ec 08             	sub    $0x8,%esp
f0101e9e:	6a 00                	push   $0x0
f0101ea0:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101ea6:	89 c6                	mov    %eax,%esi
f0101ea8:	ff 30                	pushl  (%eax)
f0101eaa:	e8 de f3 ff ff       	call   f010128d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101eaf:	8b 06                	mov    (%esi),%eax
f0101eb1:	89 c6                	mov    %eax,%esi
f0101eb3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eb8:	e8 53 eb ff ff       	call   f0100a10 <check_va2pa>
f0101ebd:	83 c4 10             	add    $0x10,%esp
f0101ec0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ec3:	0f 85 6f 08 00 00    	jne    f0102738 <mem_init+0x13e0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ec9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ece:	89 f0                	mov    %esi,%eax
f0101ed0:	e8 3b eb ff ff       	call   f0100a10 <check_va2pa>
f0101ed5:	c7 c2 d0 96 11 f0    	mov    $0xf01196d0,%edx
f0101edb:	89 f9                	mov    %edi,%ecx
f0101edd:	2b 0a                	sub    (%edx),%ecx
f0101edf:	89 ca                	mov    %ecx,%edx
f0101ee1:	c1 fa 03             	sar    $0x3,%edx
f0101ee4:	c1 e2 0c             	shl    $0xc,%edx
f0101ee7:	39 d0                	cmp    %edx,%eax
f0101ee9:	0f 85 68 08 00 00    	jne    f0102757 <mem_init+0x13ff>
	assert(pp1->pp_ref == 1);
f0101eef:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ef4:	0f 85 7c 08 00 00    	jne    f0102776 <mem_init+0x141e>
	assert(pp2->pp_ref == 0);
f0101efa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101efd:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101f02:	0f 85 8d 08 00 00    	jne    f0102795 <mem_init+0x143d>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f08:	6a 00                	push   $0x0
f0101f0a:	68 00 10 00 00       	push   $0x1000
f0101f0f:	57                   	push   %edi
f0101f10:	56                   	push   %esi
f0101f11:	e8 bc f3 ff ff       	call   f01012d2 <page_insert>
f0101f16:	83 c4 10             	add    $0x10,%esp
f0101f19:	85 c0                	test   %eax,%eax
f0101f1b:	0f 85 93 08 00 00    	jne    f01027b4 <mem_init+0x145c>
	assert(pp1->pp_ref);
f0101f21:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f26:	0f 84 a7 08 00 00    	je     f01027d3 <mem_init+0x147b>
	assert(pp1->pp_link == NULL);
f0101f2c:	83 3f 00             	cmpl   $0x0,(%edi)
f0101f2f:	0f 85 bd 08 00 00    	jne    f01027f2 <mem_init+0x149a>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f35:	83 ec 08             	sub    $0x8,%esp
f0101f38:	68 00 10 00 00       	push   $0x1000
f0101f3d:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101f43:	89 c6                	mov    %eax,%esi
f0101f45:	ff 30                	pushl  (%eax)
f0101f47:	e8 41 f3 ff ff       	call   f010128d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f4c:	8b 06                	mov    (%esi),%eax
f0101f4e:	89 c6                	mov    %eax,%esi
f0101f50:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f55:	e8 b6 ea ff ff       	call   f0100a10 <check_va2pa>
f0101f5a:	83 c4 10             	add    $0x10,%esp
f0101f5d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f60:	0f 85 ab 08 00 00    	jne    f0102811 <mem_init+0x14b9>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f66:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f6b:	89 f0                	mov    %esi,%eax
f0101f6d:	e8 9e ea ff ff       	call   f0100a10 <check_va2pa>
f0101f72:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f75:	0f 85 b5 08 00 00    	jne    f0102830 <mem_init+0x14d8>
	assert(pp1->pp_ref == 0);
f0101f7b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f80:	0f 85 c9 08 00 00    	jne    f010284f <mem_init+0x14f7>
	assert(pp2->pp_ref == 0);
f0101f86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f89:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101f8e:	0f 85 da 08 00 00    	jne    f010286e <mem_init+0x1516>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f94:	83 ec 0c             	sub    $0xc,%esp
f0101f97:	6a 00                	push   $0x0
f0101f99:	e8 d6 ef ff ff       	call   f0100f74 <page_alloc>
f0101f9e:	83 c4 10             	add    $0x10,%esp
f0101fa1:	39 c7                	cmp    %eax,%edi
f0101fa3:	0f 85 e4 08 00 00    	jne    f010288d <mem_init+0x1535>
f0101fa9:	85 c0                	test   %eax,%eax
f0101fab:	0f 84 dc 08 00 00    	je     f010288d <mem_init+0x1535>

	// should be no free memory
	assert(!page_alloc(0));
f0101fb1:	83 ec 0c             	sub    $0xc,%esp
f0101fb4:	6a 00                	push   $0x0
f0101fb6:	e8 b9 ef ff ff       	call   f0100f74 <page_alloc>
f0101fbb:	83 c4 10             	add    $0x10,%esp
f0101fbe:	85 c0                	test   %eax,%eax
f0101fc0:	0f 85 e6 08 00 00    	jne    f01028ac <mem_init+0x1554>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101fc6:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101fcc:	8b 08                	mov    (%eax),%ecx
f0101fce:	8b 11                	mov    (%ecx),%edx
f0101fd0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101fd6:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101fdc:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101fdf:	2b 30                	sub    (%eax),%esi
f0101fe1:	89 f0                	mov    %esi,%eax
f0101fe3:	c1 f8 03             	sar    $0x3,%eax
f0101fe6:	c1 e0 0c             	shl    $0xc,%eax
f0101fe9:	39 c2                	cmp    %eax,%edx
f0101feb:	0f 85 da 08 00 00    	jne    f01028cb <mem_init+0x1573>
	kern_pgdir[0] = 0;
f0101ff1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101ff7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ffa:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101fff:	0f 85 e5 08 00 00    	jne    f01028ea <mem_init+0x1592>
	pp0->pp_ref = 0;
f0102005:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102008:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010200e:	83 ec 0c             	sub    $0xc,%esp
f0102011:	50                   	push   %eax
f0102012:	e8 e5 ef ff ff       	call   f0100ffc <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102017:	83 c4 0c             	add    $0xc,%esp
f010201a:	6a 01                	push   $0x1
f010201c:	68 00 10 40 00       	push   $0x401000
f0102021:	c7 c6 cc 96 11 f0    	mov    $0xf01196cc,%esi
f0102027:	ff 36                	pushl  (%esi)
f0102029:	e8 61 f0 ff ff       	call   f010108f <pgdir_walk>
f010202e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102031:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102034:	8b 06                	mov    (%esi),%eax
f0102036:	8b 50 04             	mov    0x4(%eax),%edx
f0102039:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010203f:	c7 c1 c8 96 11 f0    	mov    $0xf01196c8,%ecx
f0102045:	8b 09                	mov    (%ecx),%ecx
f0102047:	89 d6                	mov    %edx,%esi
f0102049:	c1 ee 0c             	shr    $0xc,%esi
f010204c:	83 c4 10             	add    $0x10,%esp
f010204f:	39 ce                	cmp    %ecx,%esi
f0102051:	0f 83 b2 08 00 00    	jae    f0102909 <mem_init+0x15b1>
	assert(ptep == ptep1 + PTX(va));
f0102057:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010205d:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0102060:	0f 85 bc 08 00 00    	jne    f0102922 <mem_init+0x15ca>
	kern_pgdir[PDX(va)] = 0;
f0102066:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010206d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102070:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
	return (pp - pages) << PGSHIFT;
f0102076:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f010207c:	2b 10                	sub    (%eax),%edx
f010207e:	89 d0                	mov    %edx,%eax
f0102080:	c1 f8 03             	sar    $0x3,%eax
f0102083:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102086:	89 c2                	mov    %eax,%edx
f0102088:	c1 ea 0c             	shr    $0xc,%edx
f010208b:	39 d1                	cmp    %edx,%ecx
f010208d:	0f 86 ae 08 00 00    	jbe    f0102941 <mem_init+0x15e9>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102093:	83 ec 04             	sub    $0x4,%esp
f0102096:	68 00 10 00 00       	push   $0x1000
f010209b:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01020a0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020a5:	50                   	push   %eax
f01020a6:	e8 fa 1a 00 00       	call   f0103ba5 <memset>
	page_free(pp0);
f01020ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01020ae:	89 34 24             	mov    %esi,(%esp)
f01020b1:	e8 46 ef ff ff       	call   f0100ffc <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020b6:	83 c4 0c             	add    $0xc,%esp
f01020b9:	6a 01                	push   $0x1
f01020bb:	6a 00                	push   $0x0
f01020bd:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f01020c3:	ff 30                	pushl  (%eax)
f01020c5:	e8 c5 ef ff ff       	call   f010108f <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01020ca:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f01020d0:	89 f2                	mov    %esi,%edx
f01020d2:	2b 10                	sub    (%eax),%edx
f01020d4:	c1 fa 03             	sar    $0x3,%edx
f01020d7:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01020da:	89 d1                	mov    %edx,%ecx
f01020dc:	c1 e9 0c             	shr    $0xc,%ecx
f01020df:	83 c4 10             	add    $0x10,%esp
f01020e2:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01020e8:	3b 08                	cmp    (%eax),%ecx
f01020ea:	0f 83 67 08 00 00    	jae    f0102957 <mem_init+0x15ff>
	return (void *)(pa + KERNBASE);
f01020f0:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01020f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01020f9:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f01020ff:	8b 75 d4             	mov    -0x2c(%ebp),%esi
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102102:	f6 00 01             	testb  $0x1,(%eax)
f0102105:	0f 85 62 08 00 00    	jne    f010296d <mem_init+0x1615>
f010210b:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f010210e:	39 d0                	cmp    %edx,%eax
f0102110:	75 f0                	jne    f0102102 <mem_init+0xdaa>
	kern_pgdir[0] = 0;
f0102112:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0102118:	8b 00                	mov    (%eax),%eax
f010211a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102120:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102123:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102129:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010212c:	89 8b 94 1f 00 00    	mov    %ecx,0x1f94(%ebx)

	// free the pages we took
	page_free(pp0);
f0102132:	83 ec 0c             	sub    $0xc,%esp
f0102135:	50                   	push   %eax
f0102136:	e8 c1 ee ff ff       	call   f0100ffc <page_free>
	page_free(pp1);
f010213b:	89 3c 24             	mov    %edi,(%esp)
f010213e:	e8 b9 ee ff ff       	call   f0100ffc <page_free>
	page_free(pp2);
f0102143:	89 34 24             	mov    %esi,(%esp)
f0102146:	e8 b1 ee ff ff       	call   f0100ffc <page_free>

	cprintf("check_page() succeeded!\n");
f010214b:	8d 83 6b d4 fe ff    	lea    -0x12b95(%ebx),%eax
f0102151:	89 04 24             	mov    %eax,(%esp)
f0102154:	e8 f0 0e 00 00       	call   f0103049 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102159:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f010215f:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102161:	83 c4 10             	add    $0x10,%esp
f0102164:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102169:	0f 86 1d 08 00 00    	jbe    f010298c <mem_init+0x1634>
f010216f:	83 ec 08             	sub    $0x8,%esp
f0102172:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102174:	05 00 00 00 10       	add    $0x10000000,%eax
f0102179:	50                   	push   %eax
f010217a:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010217f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102184:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f010218a:	8b 00                	mov    (%eax),%eax
f010218c:	e8 f2 ef ff ff       	call   f0101183 <boot_map_region>
	cprintf("pages\n");
f0102191:	8d 83 84 d4 fe ff    	lea    -0x12b7c(%ebx),%eax
f0102197:	89 04 24             	mov    %eax,(%esp)
f010219a:	e8 aa 0e 00 00       	call   f0103049 <cprintf>
	if ((uint32_t)kva < KERNBASE)
f010219f:	c7 c0 00 e0 10 f0    	mov    $0xf010e000,%eax
f01021a5:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01021a8:	83 c4 10             	add    $0x10,%esp
f01021ab:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021b0:	0f 86 ef 07 00 00    	jbe    f01029a5 <mem_init+0x164d>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01021b6:	c7 c6 cc 96 11 f0    	mov    $0xf01196cc,%esi
f01021bc:	83 ec 08             	sub    $0x8,%esp
f01021bf:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f01021c1:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01021c4:	05 00 00 00 10       	add    $0x10000000,%eax
f01021c9:	50                   	push   %eax
f01021ca:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01021cf:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01021d4:	8b 06                	mov    (%esi),%eax
f01021d6:	e8 a8 ef ff ff       	call   f0101183 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f01021db:	83 c4 08             	add    $0x8,%esp
f01021de:	6a 02                	push   $0x2
f01021e0:	6a 00                	push   $0x0
f01021e2:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01021e7:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01021ec:	8b 06                	mov    (%esi),%eax
f01021ee:	e8 90 ef ff ff       	call   f0101183 <boot_map_region>
	pgdir = kern_pgdir;
f01021f3:	8b 36                	mov    (%esi),%esi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01021f5:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01021fb:	8b 00                	mov    (%eax),%eax
f01021fd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102200:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102207:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010220c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010220f:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102215:	8b 00                	mov    (%eax),%eax
f0102217:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f010221a:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f010221d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102222:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f0102225:	bf 00 00 00 00       	mov    $0x0,%edi
f010222a:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010222d:	89 c6                	mov    %eax,%esi
f010222f:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0102232:	0f 86 c0 07 00 00    	jbe    f01029f8 <mem_init+0x16a0>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102238:	8d 97 00 00 00 ef    	lea    -0x11000000(%edi),%edx
f010223e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102241:	e8 ca e7 ff ff       	call   f0100a10 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102246:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f010224d:	0f 86 6b 07 00 00    	jbe    f01029be <mem_init+0x1666>
f0102253:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102256:	39 c2                	cmp    %eax,%edx
f0102258:	0f 85 7b 07 00 00    	jne    f01029d9 <mem_init+0x1681>
	for (i = 0; i < n; i += PGSIZE)
f010225e:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0102264:	eb c9                	jmp    f010222f <mem_init+0xed7>
	assert(nfree == 0);
f0102266:	8d 83 94 d3 fe ff    	lea    -0x12c6c(%ebx),%eax
f010226c:	50                   	push   %eax
f010226d:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102273:	50                   	push   %eax
f0102274:	68 ac 02 00 00       	push   $0x2ac
f0102279:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010227f:	50                   	push   %eax
f0102280:	e8 14 de ff ff       	call   f0100099 <_panic>
	assert((pp0 = page_alloc(0)));
f0102285:	8d 83 81 d2 fe ff    	lea    -0x12d7f(%ebx),%eax
f010228b:	50                   	push   %eax
f010228c:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102292:	50                   	push   %eax
f0102293:	68 05 03 00 00       	push   $0x305
f0102298:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010229e:	50                   	push   %eax
f010229f:	e8 f5 dd ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f01022a4:	8d 83 97 d2 fe ff    	lea    -0x12d69(%ebx),%eax
f01022aa:	50                   	push   %eax
f01022ab:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01022b1:	50                   	push   %eax
f01022b2:	68 06 03 00 00       	push   $0x306
f01022b7:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01022bd:	50                   	push   %eax
f01022be:	e8 d6 dd ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f01022c3:	8d 83 ad d2 fe ff    	lea    -0x12d53(%ebx),%eax
f01022c9:	50                   	push   %eax
f01022ca:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01022d0:	50                   	push   %eax
f01022d1:	68 07 03 00 00       	push   $0x307
f01022d6:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01022dc:	50                   	push   %eax
f01022dd:	e8 b7 dd ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f01022e2:	8d 83 c3 d2 fe ff    	lea    -0x12d3d(%ebx),%eax
f01022e8:	50                   	push   %eax
f01022e9:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01022ef:	50                   	push   %eax
f01022f0:	68 0a 03 00 00       	push   $0x30a
f01022f5:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01022fb:	50                   	push   %eax
f01022fc:	e8 98 dd ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102301:	8d 83 5c d7 fe ff    	lea    -0x128a4(%ebx),%eax
f0102307:	50                   	push   %eax
f0102308:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010230e:	50                   	push   %eax
f010230f:	68 0b 03 00 00       	push   $0x30b
f0102314:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010231a:	50                   	push   %eax
f010231b:	e8 79 dd ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0102320:	8d 83 2c d3 fe ff    	lea    -0x12cd4(%ebx),%eax
f0102326:	50                   	push   %eax
f0102327:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010232d:	50                   	push   %eax
f010232e:	68 12 03 00 00       	push   $0x312
f0102333:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102339:	50                   	push   %eax
f010233a:	e8 5a dd ff ff       	call   f0100099 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010233f:	8d 83 9c d7 fe ff    	lea    -0x12864(%ebx),%eax
f0102345:	50                   	push   %eax
f0102346:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010234c:	50                   	push   %eax
f010234d:	68 15 03 00 00       	push   $0x315
f0102352:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102358:	50                   	push   %eax
f0102359:	e8 3b dd ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010235e:	8d 83 d4 d7 fe ff    	lea    -0x1282c(%ebx),%eax
f0102364:	50                   	push   %eax
f0102365:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010236b:	50                   	push   %eax
f010236c:	68 18 03 00 00       	push   $0x318
f0102371:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102377:	50                   	push   %eax
f0102378:	e8 1c dd ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010237d:	8d 83 04 d8 fe ff    	lea    -0x127fc(%ebx),%eax
f0102383:	50                   	push   %eax
f0102384:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010238a:	50                   	push   %eax
f010238b:	68 1c 03 00 00       	push   $0x31c
f0102390:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102396:	50                   	push   %eax
f0102397:	e8 fd dc ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010239c:	8d 83 34 d8 fe ff    	lea    -0x127cc(%ebx),%eax
f01023a2:	50                   	push   %eax
f01023a3:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01023a9:	50                   	push   %eax
f01023aa:	68 1d 03 00 00       	push   $0x31d
f01023af:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01023b5:	50                   	push   %eax
f01023b6:	e8 de dc ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01023bb:	8d 83 5c d8 fe ff    	lea    -0x127a4(%ebx),%eax
f01023c1:	50                   	push   %eax
f01023c2:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01023c8:	50                   	push   %eax
f01023c9:	68 1e 03 00 00       	push   $0x31e
f01023ce:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01023d4:	50                   	push   %eax
f01023d5:	e8 bf dc ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f01023da:	8d 83 9f d3 fe ff    	lea    -0x12c61(%ebx),%eax
f01023e0:	50                   	push   %eax
f01023e1:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01023e7:	50                   	push   %eax
f01023e8:	68 1f 03 00 00       	push   $0x31f
f01023ed:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01023f3:	50                   	push   %eax
f01023f4:	e8 a0 dc ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f01023f9:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01023ff:	50                   	push   %eax
f0102400:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102406:	50                   	push   %eax
f0102407:	68 20 03 00 00       	push   $0x320
f010240c:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102412:	50                   	push   %eax
f0102413:	e8 81 dc ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102418:	8d 83 8c d8 fe ff    	lea    -0x12774(%ebx),%eax
f010241e:	50                   	push   %eax
f010241f:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102425:	50                   	push   %eax
f0102426:	68 23 03 00 00       	push   $0x323
f010242b:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102431:	50                   	push   %eax
f0102432:	e8 62 dc ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102437:	8d 83 c8 d8 fe ff    	lea    -0x12738(%ebx),%eax
f010243d:	50                   	push   %eax
f010243e:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102444:	50                   	push   %eax
f0102445:	68 24 03 00 00       	push   $0x324
f010244a:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102450:	50                   	push   %eax
f0102451:	e8 43 dc ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f0102456:	8d 83 c1 d3 fe ff    	lea    -0x12c3f(%ebx),%eax
f010245c:	50                   	push   %eax
f010245d:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102463:	50                   	push   %eax
f0102464:	68 25 03 00 00       	push   $0x325
f0102469:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010246f:	50                   	push   %eax
f0102470:	e8 24 dc ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0102475:	8d 83 2c d3 fe ff    	lea    -0x12cd4(%ebx),%eax
f010247b:	50                   	push   %eax
f010247c:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102482:	50                   	push   %eax
f0102483:	68 28 03 00 00       	push   $0x328
f0102488:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010248e:	50                   	push   %eax
f010248f:	e8 05 dc ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102494:	8d 83 8c d8 fe ff    	lea    -0x12774(%ebx),%eax
f010249a:	50                   	push   %eax
f010249b:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01024a1:	50                   	push   %eax
f01024a2:	68 2b 03 00 00       	push   $0x32b
f01024a7:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01024ad:	50                   	push   %eax
f01024ae:	e8 e6 db ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024b3:	8d 83 c8 d8 fe ff    	lea    -0x12738(%ebx),%eax
f01024b9:	50                   	push   %eax
f01024ba:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01024c0:	50                   	push   %eax
f01024c1:	68 2c 03 00 00       	push   $0x32c
f01024c6:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01024cc:	50                   	push   %eax
f01024cd:	e8 c7 db ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f01024d2:	8d 83 c1 d3 fe ff    	lea    -0x12c3f(%ebx),%eax
f01024d8:	50                   	push   %eax
f01024d9:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01024df:	50                   	push   %eax
f01024e0:	68 2d 03 00 00       	push   $0x32d
f01024e5:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01024eb:	50                   	push   %eax
f01024ec:	e8 a8 db ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f01024f1:	8d 83 2c d3 fe ff    	lea    -0x12cd4(%ebx),%eax
f01024f7:	50                   	push   %eax
f01024f8:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01024fe:	50                   	push   %eax
f01024ff:	68 31 03 00 00       	push   $0x331
f0102504:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010250a:	50                   	push   %eax
f010250b:	e8 89 db ff ff       	call   f0100099 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102510:	50                   	push   %eax
f0102511:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f0102517:	50                   	push   %eax
f0102518:	68 34 03 00 00       	push   $0x334
f010251d:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102523:	50                   	push   %eax
f0102524:	e8 70 db ff ff       	call   f0100099 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102529:	8d 83 f8 d8 fe ff    	lea    -0x12708(%ebx),%eax
f010252f:	50                   	push   %eax
f0102530:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102536:	50                   	push   %eax
f0102537:	68 35 03 00 00       	push   $0x335
f010253c:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102542:	50                   	push   %eax
f0102543:	e8 51 db ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102548:	8d 83 38 d9 fe ff    	lea    -0x126c8(%ebx),%eax
f010254e:	50                   	push   %eax
f010254f:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102555:	50                   	push   %eax
f0102556:	68 38 03 00 00       	push   $0x338
f010255b:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102561:	50                   	push   %eax
f0102562:	e8 32 db ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102567:	8d 83 c8 d8 fe ff    	lea    -0x12738(%ebx),%eax
f010256d:	50                   	push   %eax
f010256e:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102574:	50                   	push   %eax
f0102575:	68 39 03 00 00       	push   $0x339
f010257a:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102580:	50                   	push   %eax
f0102581:	e8 13 db ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f0102586:	8d 83 c1 d3 fe ff    	lea    -0x12c3f(%ebx),%eax
f010258c:	50                   	push   %eax
f010258d:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102593:	50                   	push   %eax
f0102594:	68 3a 03 00 00       	push   $0x33a
f0102599:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010259f:	50                   	push   %eax
f01025a0:	e8 f4 da ff ff       	call   f0100099 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01025a5:	8d 83 78 d9 fe ff    	lea    -0x12688(%ebx),%eax
f01025ab:	50                   	push   %eax
f01025ac:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01025b2:	50                   	push   %eax
f01025b3:	68 3b 03 00 00       	push   $0x33b
f01025b8:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01025be:	50                   	push   %eax
f01025bf:	e8 d5 da ff ff       	call   f0100099 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01025c4:	8d 83 d2 d3 fe ff    	lea    -0x12c2e(%ebx),%eax
f01025ca:	50                   	push   %eax
f01025cb:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01025d1:	50                   	push   %eax
f01025d2:	68 3c 03 00 00       	push   $0x33c
f01025d7:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01025dd:	50                   	push   %eax
f01025de:	e8 b6 da ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025e3:	8d 83 8c d8 fe ff    	lea    -0x12774(%ebx),%eax
f01025e9:	50                   	push   %eax
f01025ea:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01025f0:	50                   	push   %eax
f01025f1:	68 3f 03 00 00       	push   $0x33f
f01025f6:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01025fc:	50                   	push   %eax
f01025fd:	e8 97 da ff ff       	call   f0100099 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102602:	8d 83 ac d9 fe ff    	lea    -0x12654(%ebx),%eax
f0102608:	50                   	push   %eax
f0102609:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010260f:	50                   	push   %eax
f0102610:	68 40 03 00 00       	push   $0x340
f0102615:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010261b:	50                   	push   %eax
f010261c:	e8 78 da ff ff       	call   f0100099 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102621:	8d 83 e0 d9 fe ff    	lea    -0x12620(%ebx),%eax
f0102627:	50                   	push   %eax
f0102628:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010262e:	50                   	push   %eax
f010262f:	68 41 03 00 00       	push   $0x341
f0102634:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010263a:	50                   	push   %eax
f010263b:	e8 59 da ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102640:	8d 83 18 da fe ff    	lea    -0x125e8(%ebx),%eax
f0102646:	50                   	push   %eax
f0102647:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010264d:	50                   	push   %eax
f010264e:	68 44 03 00 00       	push   $0x344
f0102653:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102659:	50                   	push   %eax
f010265a:	e8 3a da ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010265f:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102665:	50                   	push   %eax
f0102666:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010266c:	50                   	push   %eax
f010266d:	68 47 03 00 00       	push   $0x347
f0102672:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102678:	50                   	push   %eax
f0102679:	e8 1b da ff ff       	call   f0100099 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010267e:	8d 83 e0 d9 fe ff    	lea    -0x12620(%ebx),%eax
f0102684:	50                   	push   %eax
f0102685:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010268b:	50                   	push   %eax
f010268c:	68 48 03 00 00       	push   $0x348
f0102691:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102697:	50                   	push   %eax
f0102698:	e8 fc d9 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010269d:	8d 83 8c da fe ff    	lea    -0x12574(%ebx),%eax
f01026a3:	50                   	push   %eax
f01026a4:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01026aa:	50                   	push   %eax
f01026ab:	68 4b 03 00 00       	push   $0x34b
f01026b0:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01026b6:	50                   	push   %eax
f01026b7:	e8 dd d9 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026bc:	8d 83 b8 da fe ff    	lea    -0x12548(%ebx),%eax
f01026c2:	50                   	push   %eax
f01026c3:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01026c9:	50                   	push   %eax
f01026ca:	68 4c 03 00 00       	push   $0x34c
f01026cf:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01026d5:	50                   	push   %eax
f01026d6:	e8 be d9 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 2);
f01026db:	8d 83 e8 d3 fe ff    	lea    -0x12c18(%ebx),%eax
f01026e1:	50                   	push   %eax
f01026e2:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01026e8:	50                   	push   %eax
f01026e9:	68 4e 03 00 00       	push   $0x34e
f01026ee:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01026f4:	50                   	push   %eax
f01026f5:	e8 9f d9 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f01026fa:	8d 83 f9 d3 fe ff    	lea    -0x12c07(%ebx),%eax
f0102700:	50                   	push   %eax
f0102701:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102707:	50                   	push   %eax
f0102708:	68 4f 03 00 00       	push   $0x34f
f010270d:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102713:	50                   	push   %eax
f0102714:	e8 80 d9 ff ff       	call   f0100099 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102719:	8d 83 e8 da fe ff    	lea    -0x12518(%ebx),%eax
f010271f:	50                   	push   %eax
f0102720:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102726:	50                   	push   %eax
f0102727:	68 52 03 00 00       	push   $0x352
f010272c:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102732:	50                   	push   %eax
f0102733:	e8 61 d9 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102738:	8d 83 0c db fe ff    	lea    -0x124f4(%ebx),%eax
f010273e:	50                   	push   %eax
f010273f:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102745:	50                   	push   %eax
f0102746:	68 56 03 00 00       	push   $0x356
f010274b:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102751:	50                   	push   %eax
f0102752:	e8 42 d9 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102757:	8d 83 b8 da fe ff    	lea    -0x12548(%ebx),%eax
f010275d:	50                   	push   %eax
f010275e:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102764:	50                   	push   %eax
f0102765:	68 57 03 00 00       	push   $0x357
f010276a:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102770:	50                   	push   %eax
f0102771:	e8 23 d9 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f0102776:	8d 83 9f d3 fe ff    	lea    -0x12c61(%ebx),%eax
f010277c:	50                   	push   %eax
f010277d:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102783:	50                   	push   %eax
f0102784:	68 58 03 00 00       	push   $0x358
f0102789:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010278f:	50                   	push   %eax
f0102790:	e8 04 d9 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f0102795:	8d 83 f9 d3 fe ff    	lea    -0x12c07(%ebx),%eax
f010279b:	50                   	push   %eax
f010279c:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01027a2:	50                   	push   %eax
f01027a3:	68 59 03 00 00       	push   $0x359
f01027a8:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01027ae:	50                   	push   %eax
f01027af:	e8 e5 d8 ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01027b4:	8d 83 30 db fe ff    	lea    -0x124d0(%ebx),%eax
f01027ba:	50                   	push   %eax
f01027bb:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01027c1:	50                   	push   %eax
f01027c2:	68 5c 03 00 00       	push   $0x35c
f01027c7:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01027cd:	50                   	push   %eax
f01027ce:	e8 c6 d8 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref);
f01027d3:	8d 83 0a d4 fe ff    	lea    -0x12bf6(%ebx),%eax
f01027d9:	50                   	push   %eax
f01027da:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01027e0:	50                   	push   %eax
f01027e1:	68 5d 03 00 00       	push   $0x35d
f01027e6:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01027ec:	50                   	push   %eax
f01027ed:	e8 a7 d8 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_link == NULL);
f01027f2:	8d 83 16 d4 fe ff    	lea    -0x12bea(%ebx),%eax
f01027f8:	50                   	push   %eax
f01027f9:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01027ff:	50                   	push   %eax
f0102800:	68 5e 03 00 00       	push   $0x35e
f0102805:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010280b:	50                   	push   %eax
f010280c:	e8 88 d8 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102811:	8d 83 0c db fe ff    	lea    -0x124f4(%ebx),%eax
f0102817:	50                   	push   %eax
f0102818:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010281e:	50                   	push   %eax
f010281f:	68 62 03 00 00       	push   $0x362
f0102824:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010282a:	50                   	push   %eax
f010282b:	e8 69 d8 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102830:	8d 83 68 db fe ff    	lea    -0x12498(%ebx),%eax
f0102836:	50                   	push   %eax
f0102837:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010283d:	50                   	push   %eax
f010283e:	68 63 03 00 00       	push   $0x363
f0102843:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102849:	50                   	push   %eax
f010284a:	e8 4a d8 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 0);
f010284f:	8d 83 2b d4 fe ff    	lea    -0x12bd5(%ebx),%eax
f0102855:	50                   	push   %eax
f0102856:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010285c:	50                   	push   %eax
f010285d:	68 64 03 00 00       	push   $0x364
f0102862:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102868:	50                   	push   %eax
f0102869:	e8 2b d8 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f010286e:	8d 83 f9 d3 fe ff    	lea    -0x12c07(%ebx),%eax
f0102874:	50                   	push   %eax
f0102875:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010287b:	50                   	push   %eax
f010287c:	68 65 03 00 00       	push   $0x365
f0102881:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102887:	50                   	push   %eax
f0102888:	e8 0c d8 ff ff       	call   f0100099 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010288d:	8d 83 90 db fe ff    	lea    -0x12470(%ebx),%eax
f0102893:	50                   	push   %eax
f0102894:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010289a:	50                   	push   %eax
f010289b:	68 68 03 00 00       	push   $0x368
f01028a0:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01028a6:	50                   	push   %eax
f01028a7:	e8 ed d7 ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f01028ac:	8d 83 2c d3 fe ff    	lea    -0x12cd4(%ebx),%eax
f01028b2:	50                   	push   %eax
f01028b3:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01028b9:	50                   	push   %eax
f01028ba:	68 6b 03 00 00       	push   $0x36b
f01028bf:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01028c5:	50                   	push   %eax
f01028c6:	e8 ce d7 ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01028cb:	8d 83 34 d8 fe ff    	lea    -0x127cc(%ebx),%eax
f01028d1:	50                   	push   %eax
f01028d2:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01028d8:	50                   	push   %eax
f01028d9:	68 6e 03 00 00       	push   $0x36e
f01028de:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01028e4:	50                   	push   %eax
f01028e5:	e8 af d7 ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f01028ea:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f01028f0:	50                   	push   %eax
f01028f1:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01028f7:	50                   	push   %eax
f01028f8:	68 70 03 00 00       	push   $0x370
f01028fd:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102903:	50                   	push   %eax
f0102904:	e8 90 d7 ff ff       	call   f0100099 <_panic>
f0102909:	52                   	push   %edx
f010290a:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f0102910:	50                   	push   %eax
f0102911:	68 77 03 00 00       	push   $0x377
f0102916:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010291c:	50                   	push   %eax
f010291d:	e8 77 d7 ff ff       	call   f0100099 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102922:	8d 83 3c d4 fe ff    	lea    -0x12bc4(%ebx),%eax
f0102928:	50                   	push   %eax
f0102929:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010292f:	50                   	push   %eax
f0102930:	68 78 03 00 00       	push   $0x378
f0102935:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010293b:	50                   	push   %eax
f010293c:	e8 58 d7 ff ff       	call   f0100099 <_panic>
f0102941:	50                   	push   %eax
f0102942:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f0102948:	50                   	push   %eax
f0102949:	6a 52                	push   $0x52
f010294b:	8d 83 75 d1 fe ff    	lea    -0x12e8b(%ebx),%eax
f0102951:	50                   	push   %eax
f0102952:	e8 42 d7 ff ff       	call   f0100099 <_panic>
f0102957:	52                   	push   %edx
f0102958:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f010295e:	50                   	push   %eax
f010295f:	6a 52                	push   $0x52
f0102961:	8d 83 75 d1 fe ff    	lea    -0x12e8b(%ebx),%eax
f0102967:	50                   	push   %eax
f0102968:	e8 2c d7 ff ff       	call   f0100099 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010296d:	8d 83 54 d4 fe ff    	lea    -0x12bac(%ebx),%eax
f0102973:	50                   	push   %eax
f0102974:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f010297a:	50                   	push   %eax
f010297b:	68 82 03 00 00       	push   $0x382
f0102980:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102986:	50                   	push   %eax
f0102987:	e8 0d d7 ff ff       	call   f0100099 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010298c:	50                   	push   %eax
f010298d:	8d 83 10 d7 fe ff    	lea    -0x128f0(%ebx),%eax
f0102993:	50                   	push   %eax
f0102994:	68 b8 00 00 00       	push   $0xb8
f0102999:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f010299f:	50                   	push   %eax
f01029a0:	e8 f4 d6 ff ff       	call   f0100099 <_panic>
f01029a5:	50                   	push   %eax
f01029a6:	8d 83 10 d7 fe ff    	lea    -0x128f0(%ebx),%eax
f01029ac:	50                   	push   %eax
f01029ad:	68 c6 00 00 00       	push   $0xc6
f01029b2:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01029b8:	50                   	push   %eax
f01029b9:	e8 db d6 ff ff       	call   f0100099 <_panic>
f01029be:	ff 75 c0             	pushl  -0x40(%ebp)
f01029c1:	8d 83 10 d7 fe ff    	lea    -0x128f0(%ebx),%eax
f01029c7:	50                   	push   %eax
f01029c8:	68 c4 02 00 00       	push   $0x2c4
f01029cd:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01029d3:	50                   	push   %eax
f01029d4:	e8 c0 d6 ff ff       	call   f0100099 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01029d9:	8d 83 b4 db fe ff    	lea    -0x1244c(%ebx),%eax
f01029df:	50                   	push   %eax
f01029e0:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f01029e6:	50                   	push   %eax
f01029e7:	68 c4 02 00 00       	push   $0x2c4
f01029ec:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f01029f2:	50                   	push   %eax
f01029f3:	e8 a1 d6 ff ff       	call   f0100099 <_panic>
f01029f8:	8b 75 d0             	mov    -0x30(%ebp),%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029fb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01029fe:	c1 e0 0c             	shl    $0xc,%eax
f0102a01:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a04:	bf 00 00 00 00       	mov    $0x0,%edi
f0102a09:	eb 17                	jmp    f0102a22 <mem_init+0x16ca>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a0b:	8d 97 00 00 00 f0    	lea    -0x10000000(%edi),%edx
f0102a11:	89 f0                	mov    %esi,%eax
f0102a13:	e8 f8 df ff ff       	call   f0100a10 <check_va2pa>
f0102a18:	39 c7                	cmp    %eax,%edi
f0102a1a:	75 57                	jne    f0102a73 <mem_init+0x171b>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a1c:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0102a22:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102a25:	72 e4                	jb     f0102a0b <mem_init+0x16b3>
f0102a27:	bf 00 80 ff ef       	mov    $0xefff8000,%edi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a2c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102a2f:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a34:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a37:	89 fa                	mov    %edi,%edx
f0102a39:	89 f0                	mov    %esi,%eax
f0102a3b:	e8 d0 df ff ff       	call   f0100a10 <check_va2pa>
f0102a40:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102a43:	8d 14 39             	lea    (%ecx,%edi,1),%edx
f0102a46:	39 c2                	cmp    %eax,%edx
f0102a48:	75 48                	jne    f0102a92 <mem_init+0x173a>
f0102a4a:	81 c7 00 10 00 00    	add    $0x1000,%edi
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a50:	81 ff 00 00 00 f0    	cmp    $0xf0000000,%edi
f0102a56:	75 df                	jne    f0102a37 <mem_init+0x16df>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a58:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a5d:	89 f0                	mov    %esi,%eax
f0102a5f:	e8 ac df ff ff       	call   f0100a10 <check_va2pa>
f0102a64:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a67:	75 48                	jne    f0102ab1 <mem_init+0x1759>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a69:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a6e:	e9 86 00 00 00       	jmp    f0102af9 <mem_init+0x17a1>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a73:	8d 83 e8 db fe ff    	lea    -0x12418(%ebx),%eax
f0102a79:	50                   	push   %eax
f0102a7a:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102a80:	50                   	push   %eax
f0102a81:	68 c9 02 00 00       	push   $0x2c9
f0102a86:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102a8c:	50                   	push   %eax
f0102a8d:	e8 07 d6 ff ff       	call   f0100099 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a92:	8d 83 10 dc fe ff    	lea    -0x123f0(%ebx),%eax
f0102a98:	50                   	push   %eax
f0102a99:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102a9f:	50                   	push   %eax
f0102aa0:	68 cd 02 00 00       	push   $0x2cd
f0102aa5:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102aab:	50                   	push   %eax
f0102aac:	e8 e8 d5 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102ab1:	8d 83 58 dc fe ff    	lea    -0x123a8(%ebx),%eax
f0102ab7:	50                   	push   %eax
f0102ab8:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102abe:	50                   	push   %eax
f0102abf:	68 ce 02 00 00       	push   $0x2ce
f0102ac4:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102aca:	50                   	push   %eax
f0102acb:	e8 c9 d5 ff ff       	call   f0100099 <_panic>
			assert(pgdir[i] & PTE_P);
f0102ad0:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102ad4:	74 4f                	je     f0102b25 <mem_init+0x17cd>
	for (i = 0; i < NPDENTRIES; i++) {
f0102ad6:	83 c0 01             	add    $0x1,%eax
f0102ad9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102ade:	0f 87 ab 00 00 00    	ja     f0102b8f <mem_init+0x1837>
		switch (i) {
f0102ae4:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102ae9:	72 0e                	jb     f0102af9 <mem_init+0x17a1>
f0102aeb:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102af0:	76 de                	jbe    f0102ad0 <mem_init+0x1778>
f0102af2:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102af7:	74 d7                	je     f0102ad0 <mem_init+0x1778>
			if (i >= PDX(KERNBASE)) {
f0102af9:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102afe:	77 44                	ja     f0102b44 <mem_init+0x17ec>
				assert(pgdir[i] == 0);
f0102b00:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102b04:	74 d0                	je     f0102ad6 <mem_init+0x177e>
f0102b06:	8d 83 ad d4 fe ff    	lea    -0x12b53(%ebx),%eax
f0102b0c:	50                   	push   %eax
f0102b0d:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102b13:	50                   	push   %eax
f0102b14:	68 dd 02 00 00       	push   $0x2dd
f0102b19:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102b1f:	50                   	push   %eax
f0102b20:	e8 74 d5 ff ff       	call   f0100099 <_panic>
			assert(pgdir[i] & PTE_P);
f0102b25:	8d 83 8b d4 fe ff    	lea    -0x12b75(%ebx),%eax
f0102b2b:	50                   	push   %eax
f0102b2c:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102b32:	50                   	push   %eax
f0102b33:	68 d6 02 00 00       	push   $0x2d6
f0102b38:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102b3e:	50                   	push   %eax
f0102b3f:	e8 55 d5 ff ff       	call   f0100099 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b44:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102b47:	f6 c2 01             	test   $0x1,%dl
f0102b4a:	74 24                	je     f0102b70 <mem_init+0x1818>
				assert(pgdir[i] & PTE_W);
f0102b4c:	f6 c2 02             	test   $0x2,%dl
f0102b4f:	75 85                	jne    f0102ad6 <mem_init+0x177e>
f0102b51:	8d 83 9c d4 fe ff    	lea    -0x12b64(%ebx),%eax
f0102b57:	50                   	push   %eax
f0102b58:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102b5e:	50                   	push   %eax
f0102b5f:	68 db 02 00 00       	push   $0x2db
f0102b64:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102b6a:	50                   	push   %eax
f0102b6b:	e8 29 d5 ff ff       	call   f0100099 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b70:	8d 83 8b d4 fe ff    	lea    -0x12b75(%ebx),%eax
f0102b76:	50                   	push   %eax
f0102b77:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102b7d:	50                   	push   %eax
f0102b7e:	68 da 02 00 00       	push   $0x2da
f0102b83:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102b89:	50                   	push   %eax
f0102b8a:	e8 0a d5 ff ff       	call   f0100099 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b8f:	83 ec 0c             	sub    $0xc,%esp
f0102b92:	8d 83 88 dc fe ff    	lea    -0x12378(%ebx),%eax
f0102b98:	50                   	push   %eax
f0102b99:	e8 ab 04 00 00       	call   f0103049 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b9e:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0102ba4:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102ba6:	83 c4 10             	add    $0x10,%esp
f0102ba9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bae:	0f 86 28 02 00 00    	jbe    f0102ddc <mem_init+0x1a84>
	return (physaddr_t)kva - KERNBASE;
f0102bb4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102bb9:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102bbc:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bc1:	e8 c7 de ff ff       	call   f0100a8d <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102bc6:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102bc9:	83 e0 f3             	and    $0xfffffff3,%eax
f0102bcc:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102bd1:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102bd4:	83 ec 0c             	sub    $0xc,%esp
f0102bd7:	6a 00                	push   $0x0
f0102bd9:	e8 96 e3 ff ff       	call   f0100f74 <page_alloc>
f0102bde:	89 c6                	mov    %eax,%esi
f0102be0:	83 c4 10             	add    $0x10,%esp
f0102be3:	85 c0                	test   %eax,%eax
f0102be5:	0f 84 0a 02 00 00    	je     f0102df5 <mem_init+0x1a9d>
	assert((pp1 = page_alloc(0)));
f0102beb:	83 ec 0c             	sub    $0xc,%esp
f0102bee:	6a 00                	push   $0x0
f0102bf0:	e8 7f e3 ff ff       	call   f0100f74 <page_alloc>
f0102bf5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102bf8:	83 c4 10             	add    $0x10,%esp
f0102bfb:	85 c0                	test   %eax,%eax
f0102bfd:	0f 84 11 02 00 00    	je     f0102e14 <mem_init+0x1abc>
	assert((pp2 = page_alloc(0)));
f0102c03:	83 ec 0c             	sub    $0xc,%esp
f0102c06:	6a 00                	push   $0x0
f0102c08:	e8 67 e3 ff ff       	call   f0100f74 <page_alloc>
f0102c0d:	89 c7                	mov    %eax,%edi
f0102c0f:	83 c4 10             	add    $0x10,%esp
f0102c12:	85 c0                	test   %eax,%eax
f0102c14:	0f 84 19 02 00 00    	je     f0102e33 <mem_init+0x1adb>
	page_free(pp0);
f0102c1a:	83 ec 0c             	sub    $0xc,%esp
f0102c1d:	56                   	push   %esi
f0102c1e:	e8 d9 e3 ff ff       	call   f0100ffc <page_free>
	return (pp - pages) << PGSHIFT;
f0102c23:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102c29:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102c2c:	2b 08                	sub    (%eax),%ecx
f0102c2e:	89 c8                	mov    %ecx,%eax
f0102c30:	c1 f8 03             	sar    $0x3,%eax
f0102c33:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c36:	89 c1                	mov    %eax,%ecx
f0102c38:	c1 e9 0c             	shr    $0xc,%ecx
f0102c3b:	83 c4 10             	add    $0x10,%esp
f0102c3e:	c7 c2 c8 96 11 f0    	mov    $0xf01196c8,%edx
f0102c44:	3b 0a                	cmp    (%edx),%ecx
f0102c46:	0f 83 06 02 00 00    	jae    f0102e52 <mem_init+0x1afa>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c4c:	83 ec 04             	sub    $0x4,%esp
f0102c4f:	68 00 10 00 00       	push   $0x1000
f0102c54:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c56:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c5b:	50                   	push   %eax
f0102c5c:	e8 44 0f 00 00       	call   f0103ba5 <memset>
	return (pp - pages) << PGSHIFT;
f0102c61:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102c67:	89 f9                	mov    %edi,%ecx
f0102c69:	2b 08                	sub    (%eax),%ecx
f0102c6b:	89 c8                	mov    %ecx,%eax
f0102c6d:	c1 f8 03             	sar    $0x3,%eax
f0102c70:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c73:	89 c1                	mov    %eax,%ecx
f0102c75:	c1 e9 0c             	shr    $0xc,%ecx
f0102c78:	83 c4 10             	add    $0x10,%esp
f0102c7b:	c7 c2 c8 96 11 f0    	mov    $0xf01196c8,%edx
f0102c81:	3b 0a                	cmp    (%edx),%ecx
f0102c83:	0f 83 df 01 00 00    	jae    f0102e68 <mem_init+0x1b10>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c89:	83 ec 04             	sub    $0x4,%esp
f0102c8c:	68 00 10 00 00       	push   $0x1000
f0102c91:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c93:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c98:	50                   	push   %eax
f0102c99:	e8 07 0f 00 00       	call   f0103ba5 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c9e:	6a 02                	push   $0x2
f0102ca0:	68 00 10 00 00       	push   $0x1000
f0102ca5:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102ca8:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0102cae:	ff 30                	pushl  (%eax)
f0102cb0:	e8 1d e6 ff ff       	call   f01012d2 <page_insert>
	assert(pp1->pp_ref == 1);
f0102cb5:	83 c4 20             	add    $0x20,%esp
f0102cb8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cbb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102cc0:	0f 85 b8 01 00 00    	jne    f0102e7e <mem_init+0x1b26>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cc6:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102ccd:	01 01 01 
f0102cd0:	0f 85 c7 01 00 00    	jne    f0102e9d <mem_init+0x1b45>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102cd6:	6a 02                	push   $0x2
f0102cd8:	68 00 10 00 00       	push   $0x1000
f0102cdd:	57                   	push   %edi
f0102cde:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0102ce4:	ff 30                	pushl  (%eax)
f0102ce6:	e8 e7 e5 ff ff       	call   f01012d2 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ceb:	83 c4 10             	add    $0x10,%esp
f0102cee:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cf5:	02 02 02 
f0102cf8:	0f 85 be 01 00 00    	jne    f0102ebc <mem_init+0x1b64>
	assert(pp2->pp_ref == 1);
f0102cfe:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d03:	0f 85 d2 01 00 00    	jne    f0102edb <mem_init+0x1b83>
	assert(pp1->pp_ref == 0);
f0102d09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d0c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102d11:	0f 85 e3 01 00 00    	jne    f0102efa <mem_init+0x1ba2>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d17:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d1e:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102d21:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102d27:	89 f9                	mov    %edi,%ecx
f0102d29:	2b 08                	sub    (%eax),%ecx
f0102d2b:	89 c8                	mov    %ecx,%eax
f0102d2d:	c1 f8 03             	sar    $0x3,%eax
f0102d30:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102d33:	89 c1                	mov    %eax,%ecx
f0102d35:	c1 e9 0c             	shr    $0xc,%ecx
f0102d38:	c7 c2 c8 96 11 f0    	mov    $0xf01196c8,%edx
f0102d3e:	3b 0a                	cmp    (%edx),%ecx
f0102d40:	0f 83 d3 01 00 00    	jae    f0102f19 <mem_init+0x1bc1>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d46:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d4d:	03 03 03 
f0102d50:	0f 85 d9 01 00 00    	jne    f0102f2f <mem_init+0x1bd7>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d56:	83 ec 08             	sub    $0x8,%esp
f0102d59:	68 00 10 00 00       	push   $0x1000
f0102d5e:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0102d64:	ff 30                	pushl  (%eax)
f0102d66:	e8 22 e5 ff ff       	call   f010128d <page_remove>
	assert(pp2->pp_ref == 0);
f0102d6b:	83 c4 10             	add    $0x10,%esp
f0102d6e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d73:	0f 85 d5 01 00 00    	jne    f0102f4e <mem_init+0x1bf6>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d79:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0102d7f:	8b 08                	mov    (%eax),%ecx
f0102d81:	8b 11                	mov    (%ecx),%edx
f0102d83:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d89:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102d8f:	89 f7                	mov    %esi,%edi
f0102d91:	2b 38                	sub    (%eax),%edi
f0102d93:	89 f8                	mov    %edi,%eax
f0102d95:	c1 f8 03             	sar    $0x3,%eax
f0102d98:	c1 e0 0c             	shl    $0xc,%eax
f0102d9b:	39 c2                	cmp    %eax,%edx
f0102d9d:	0f 85 ca 01 00 00    	jne    f0102f6d <mem_init+0x1c15>
	kern_pgdir[0] = 0;
f0102da3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102da9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102dae:	0f 85 d8 01 00 00    	jne    f0102f8c <mem_init+0x1c34>
	pp0->pp_ref = 0;
f0102db4:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102dba:	83 ec 0c             	sub    $0xc,%esp
f0102dbd:	56                   	push   %esi
f0102dbe:	e8 39 e2 ff ff       	call   f0100ffc <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102dc3:	8d 83 1c dd fe ff    	lea    -0x122e4(%ebx),%eax
f0102dc9:	89 04 24             	mov    %eax,(%esp)
f0102dcc:	e8 78 02 00 00       	call   f0103049 <cprintf>
}
f0102dd1:	83 c4 10             	add    $0x10,%esp
f0102dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dd7:	5b                   	pop    %ebx
f0102dd8:	5e                   	pop    %esi
f0102dd9:	5f                   	pop    %edi
f0102dda:	5d                   	pop    %ebp
f0102ddb:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ddc:	50                   	push   %eax
f0102ddd:	8d 83 10 d7 fe ff    	lea    -0x128f0(%ebx),%eax
f0102de3:	50                   	push   %eax
f0102de4:	68 dd 00 00 00       	push   $0xdd
f0102de9:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102def:	50                   	push   %eax
f0102df0:	e8 a4 d2 ff ff       	call   f0100099 <_panic>
	assert((pp0 = page_alloc(0)));
f0102df5:	8d 83 81 d2 fe ff    	lea    -0x12d7f(%ebx),%eax
f0102dfb:	50                   	push   %eax
f0102dfc:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102e02:	50                   	push   %eax
f0102e03:	68 9d 03 00 00       	push   $0x39d
f0102e08:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102e0e:	50                   	push   %eax
f0102e0f:	e8 85 d2 ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e14:	8d 83 97 d2 fe ff    	lea    -0x12d69(%ebx),%eax
f0102e1a:	50                   	push   %eax
f0102e1b:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102e21:	50                   	push   %eax
f0102e22:	68 9e 03 00 00       	push   $0x39e
f0102e27:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102e2d:	50                   	push   %eax
f0102e2e:	e8 66 d2 ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e33:	8d 83 ad d2 fe ff    	lea    -0x12d53(%ebx),%eax
f0102e39:	50                   	push   %eax
f0102e3a:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102e40:	50                   	push   %eax
f0102e41:	68 9f 03 00 00       	push   $0x39f
f0102e46:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102e4c:	50                   	push   %eax
f0102e4d:	e8 47 d2 ff ff       	call   f0100099 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e52:	50                   	push   %eax
f0102e53:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f0102e59:	50                   	push   %eax
f0102e5a:	6a 52                	push   $0x52
f0102e5c:	8d 83 75 d1 fe ff    	lea    -0x12e8b(%ebx),%eax
f0102e62:	50                   	push   %eax
f0102e63:	e8 31 d2 ff ff       	call   f0100099 <_panic>
f0102e68:	50                   	push   %eax
f0102e69:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f0102e6f:	50                   	push   %eax
f0102e70:	6a 52                	push   $0x52
f0102e72:	8d 83 75 d1 fe ff    	lea    -0x12e8b(%ebx),%eax
f0102e78:	50                   	push   %eax
f0102e79:	e8 1b d2 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f0102e7e:	8d 83 9f d3 fe ff    	lea    -0x12c61(%ebx),%eax
f0102e84:	50                   	push   %eax
f0102e85:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102e8b:	50                   	push   %eax
f0102e8c:	68 a4 03 00 00       	push   $0x3a4
f0102e91:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102e97:	50                   	push   %eax
f0102e98:	e8 fc d1 ff ff       	call   f0100099 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e9d:	8d 83 a8 dc fe ff    	lea    -0x12358(%ebx),%eax
f0102ea3:	50                   	push   %eax
f0102ea4:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102eaa:	50                   	push   %eax
f0102eab:	68 a5 03 00 00       	push   $0x3a5
f0102eb0:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102eb6:	50                   	push   %eax
f0102eb7:	e8 dd d1 ff ff       	call   f0100099 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ebc:	8d 83 cc dc fe ff    	lea    -0x12334(%ebx),%eax
f0102ec2:	50                   	push   %eax
f0102ec3:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102ec9:	50                   	push   %eax
f0102eca:	68 a7 03 00 00       	push   $0x3a7
f0102ecf:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102ed5:	50                   	push   %eax
f0102ed6:	e8 be d1 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f0102edb:	8d 83 c1 d3 fe ff    	lea    -0x12c3f(%ebx),%eax
f0102ee1:	50                   	push   %eax
f0102ee2:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102ee8:	50                   	push   %eax
f0102ee9:	68 a8 03 00 00       	push   $0x3a8
f0102eee:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102ef4:	50                   	push   %eax
f0102ef5:	e8 9f d1 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 0);
f0102efa:	8d 83 2b d4 fe ff    	lea    -0x12bd5(%ebx),%eax
f0102f00:	50                   	push   %eax
f0102f01:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102f07:	50                   	push   %eax
f0102f08:	68 a9 03 00 00       	push   $0x3a9
f0102f0d:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102f13:	50                   	push   %eax
f0102f14:	e8 80 d1 ff ff       	call   f0100099 <_panic>
f0102f19:	50                   	push   %eax
f0102f1a:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f0102f20:	50                   	push   %eax
f0102f21:	6a 52                	push   $0x52
f0102f23:	8d 83 75 d1 fe ff    	lea    -0x12e8b(%ebx),%eax
f0102f29:	50                   	push   %eax
f0102f2a:	e8 6a d1 ff ff       	call   f0100099 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f2f:	8d 83 f0 dc fe ff    	lea    -0x12310(%ebx),%eax
f0102f35:	50                   	push   %eax
f0102f36:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102f3c:	50                   	push   %eax
f0102f3d:	68 ab 03 00 00       	push   $0x3ab
f0102f42:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102f48:	50                   	push   %eax
f0102f49:	e8 4b d1 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f0102f4e:	8d 83 f9 d3 fe ff    	lea    -0x12c07(%ebx),%eax
f0102f54:	50                   	push   %eax
f0102f55:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102f5b:	50                   	push   %eax
f0102f5c:	68 ad 03 00 00       	push   $0x3ad
f0102f61:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102f67:	50                   	push   %eax
f0102f68:	e8 2c d1 ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f6d:	8d 83 34 d8 fe ff    	lea    -0x127cc(%ebx),%eax
f0102f73:	50                   	push   %eax
f0102f74:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102f7a:	50                   	push   %eax
f0102f7b:	68 b0 03 00 00       	push   $0x3b0
f0102f80:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102f86:	50                   	push   %eax
f0102f87:	e8 0d d1 ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f0102f8c:	8d 83 b0 d3 fe ff    	lea    -0x12c50(%ebx),%eax
f0102f92:	50                   	push   %eax
f0102f93:	8d 83 a6 d1 fe ff    	lea    -0x12e5a(%ebx),%eax
f0102f99:	50                   	push   %eax
f0102f9a:	68 b2 03 00 00       	push   $0x3b2
f0102f9f:	8d 83 69 d1 fe ff    	lea    -0x12e97(%ebx),%eax
f0102fa5:	50                   	push   %eax
f0102fa6:	e8 ee d0 ff ff       	call   f0100099 <_panic>

f0102fab <tlb_invalidate>:
{
f0102fab:	55                   	push   %ebp
f0102fac:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102fae:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fb1:	0f 01 38             	invlpg (%eax)
}
f0102fb4:	5d                   	pop    %ebp
f0102fb5:	c3                   	ret    

f0102fb6 <__x86.get_pc_thunk.dx>:
f0102fb6:	8b 14 24             	mov    (%esp),%edx
f0102fb9:	c3                   	ret    

f0102fba <__x86.get_pc_thunk.cx>:
f0102fba:	8b 0c 24             	mov    (%esp),%ecx
f0102fbd:	c3                   	ret    

f0102fbe <__x86.get_pc_thunk.di>:
f0102fbe:	8b 3c 24             	mov    (%esp),%edi
f0102fc1:	c3                   	ret    

f0102fc2 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102fc2:	55                   	push   %ebp
f0102fc3:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102fc5:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fc8:	ba 70 00 00 00       	mov    $0x70,%edx
f0102fcd:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102fce:	ba 71 00 00 00       	mov    $0x71,%edx
f0102fd3:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102fd4:	0f b6 c0             	movzbl %al,%eax
}
f0102fd7:	5d                   	pop    %ebp
f0102fd8:	c3                   	ret    

f0102fd9 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102fd9:	55                   	push   %ebp
f0102fda:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102fdc:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fdf:	ba 70 00 00 00       	mov    $0x70,%edx
f0102fe4:	ee                   	out    %al,(%dx)
f0102fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fe8:	ba 71 00 00 00       	mov    $0x71,%edx
f0102fed:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102fee:	5d                   	pop    %ebp
f0102fef:	c3                   	ret    

f0102ff0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102ff0:	55                   	push   %ebp
f0102ff1:	89 e5                	mov    %esp,%ebp
f0102ff3:	53                   	push   %ebx
f0102ff4:	83 ec 10             	sub    $0x10,%esp
f0102ff7:	e8 53 d1 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0102ffc:	81 c3 0c 43 01 00    	add    $0x1430c,%ebx
	cputchar(ch);
f0103002:	ff 75 08             	pushl  0x8(%ebp)
f0103005:	e8 bc d6 ff ff       	call   f01006c6 <cputchar>
	*cnt++;
}
f010300a:	83 c4 10             	add    $0x10,%esp
f010300d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103010:	c9                   	leave  
f0103011:	c3                   	ret    

f0103012 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103012:	55                   	push   %ebp
f0103013:	89 e5                	mov    %esp,%ebp
f0103015:	53                   	push   %ebx
f0103016:	83 ec 14             	sub    $0x14,%esp
f0103019:	e8 31 d1 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010301e:	81 c3 ea 42 01 00    	add    $0x142ea,%ebx
	int cnt = 0;
f0103024:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010302b:	ff 75 0c             	pushl  0xc(%ebp)
f010302e:	ff 75 08             	pushl  0x8(%ebp)
f0103031:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103034:	50                   	push   %eax
f0103035:	8d 83 e8 bc fe ff    	lea    -0x14318(%ebx),%eax
f010303b:	50                   	push   %eax
f010303c:	e8 18 04 00 00       	call   f0103459 <vprintfmt>
	return cnt;
}
f0103041:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103044:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103047:	c9                   	leave  
f0103048:	c3                   	ret    

f0103049 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103049:	55                   	push   %ebp
f010304a:	89 e5                	mov    %esp,%ebp
f010304c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010304f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103052:	50                   	push   %eax
f0103053:	ff 75 08             	pushl  0x8(%ebp)
f0103056:	e8 b7 ff ff ff       	call   f0103012 <vcprintf>
	va_end(ap);

	return cnt;
}
f010305b:	c9                   	leave  
f010305c:	c3                   	ret    

f010305d <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010305d:	55                   	push   %ebp
f010305e:	89 e5                	mov    %esp,%ebp
f0103060:	57                   	push   %edi
f0103061:	56                   	push   %esi
f0103062:	53                   	push   %ebx
f0103063:	83 ec 14             	sub    $0x14,%esp
f0103066:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103069:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010306c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010306f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103072:	8b 32                	mov    (%edx),%esi
f0103074:	8b 01                	mov    (%ecx),%eax
f0103076:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103079:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103080:	eb 2f                	jmp    f01030b1 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103082:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0103085:	39 c6                	cmp    %eax,%esi
f0103087:	7f 49                	jg     f01030d2 <stab_binsearch+0x75>
f0103089:	0f b6 0a             	movzbl (%edx),%ecx
f010308c:	83 ea 0c             	sub    $0xc,%edx
f010308f:	39 f9                	cmp    %edi,%ecx
f0103091:	75 ef                	jne    f0103082 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103093:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103096:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103099:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010309d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01030a0:	73 35                	jae    f01030d7 <stab_binsearch+0x7a>
			*region_left = m;
f01030a2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01030a5:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f01030a7:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f01030aa:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01030b1:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01030b4:	7f 4e                	jg     f0103104 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f01030b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01030b9:	01 f0                	add    %esi,%eax
f01030bb:	89 c3                	mov    %eax,%ebx
f01030bd:	c1 eb 1f             	shr    $0x1f,%ebx
f01030c0:	01 c3                	add    %eax,%ebx
f01030c2:	d1 fb                	sar    %ebx
f01030c4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01030c7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01030ca:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01030ce:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f01030d0:	eb b3                	jmp    f0103085 <stab_binsearch+0x28>
			l = true_m + 1;
f01030d2:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f01030d5:	eb da                	jmp    f01030b1 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f01030d7:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01030da:	76 14                	jbe    f01030f0 <stab_binsearch+0x93>
			*region_right = m - 1;
f01030dc:	83 e8 01             	sub    $0x1,%eax
f01030df:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01030e2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01030e5:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f01030e7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01030ee:	eb c1                	jmp    f01030b1 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01030f0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01030f3:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01030f5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01030f9:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f01030fb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103102:	eb ad                	jmp    f01030b1 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0103104:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103108:	74 16                	je     f0103120 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010310a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010310d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010310f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103112:	8b 0e                	mov    (%esi),%ecx
f0103114:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103117:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010311a:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f010311e:	eb 12                	jmp    f0103132 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0103120:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103123:	8b 00                	mov    (%eax),%eax
f0103125:	83 e8 01             	sub    $0x1,%eax
f0103128:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010312b:	89 07                	mov    %eax,(%edi)
f010312d:	eb 16                	jmp    f0103145 <stab_binsearch+0xe8>
		     l--)
f010312f:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0103132:	39 c1                	cmp    %eax,%ecx
f0103134:	7d 0a                	jge    f0103140 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0103136:	0f b6 1a             	movzbl (%edx),%ebx
f0103139:	83 ea 0c             	sub    $0xc,%edx
f010313c:	39 fb                	cmp    %edi,%ebx
f010313e:	75 ef                	jne    f010312f <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0103140:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103143:	89 07                	mov    %eax,(%edi)
	}
}
f0103145:	83 c4 14             	add    $0x14,%esp
f0103148:	5b                   	pop    %ebx
f0103149:	5e                   	pop    %esi
f010314a:	5f                   	pop    %edi
f010314b:	5d                   	pop    %ebp
f010314c:	c3                   	ret    

f010314d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010314d:	55                   	push   %ebp
f010314e:	89 e5                	mov    %esp,%ebp
f0103150:	57                   	push   %edi
f0103151:	56                   	push   %esi
f0103152:	53                   	push   %ebx
f0103153:	83 ec 2c             	sub    $0x2c,%esp
f0103156:	e8 5f fe ff ff       	call   f0102fba <__x86.get_pc_thunk.cx>
f010315b:	81 c1 ad 41 01 00    	add    $0x141ad,%ecx
f0103161:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103164:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103167:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010316a:	8d 81 48 dd fe ff    	lea    -0x122b8(%ecx),%eax
f0103170:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0103172:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0103179:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f010317c:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0103183:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f0103186:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010318d:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103193:	0f 86 f4 00 00 00    	jbe    f010328d <debuginfo_eip+0x140>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103199:	c7 c0 c1 ba 10 f0    	mov    $0xf010bac1,%eax
f010319f:	39 81 fc ff ff ff    	cmp    %eax,-0x4(%ecx)
f01031a5:	0f 86 88 01 00 00    	jbe    f0103333 <debuginfo_eip+0x1e6>
f01031ab:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01031ae:	c7 c0 7e d8 10 f0    	mov    $0xf010d87e,%eax
f01031b4:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01031b8:	0f 85 7c 01 00 00    	jne    f010333a <debuginfo_eip+0x1ed>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01031be:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01031c5:	c7 c0 68 52 10 f0    	mov    $0xf0105268,%eax
f01031cb:	c7 c2 c0 ba 10 f0    	mov    $0xf010bac0,%edx
f01031d1:	29 c2                	sub    %eax,%edx
f01031d3:	c1 fa 02             	sar    $0x2,%edx
f01031d6:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01031dc:	83 ea 01             	sub    $0x1,%edx
f01031df:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01031e2:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01031e5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01031e8:	83 ec 08             	sub    $0x8,%esp
f01031eb:	53                   	push   %ebx
f01031ec:	6a 64                	push   $0x64
f01031ee:	e8 6a fe ff ff       	call   f010305d <stab_binsearch>
	if (lfile == 0)
f01031f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031f6:	83 c4 10             	add    $0x10,%esp
f01031f9:	85 c0                	test   %eax,%eax
f01031fb:	0f 84 40 01 00 00    	je     f0103341 <debuginfo_eip+0x1f4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103201:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103204:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103207:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010320a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010320d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103210:	83 ec 08             	sub    $0x8,%esp
f0103213:	53                   	push   %ebx
f0103214:	6a 24                	push   $0x24
f0103216:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0103219:	c7 c0 68 52 10 f0    	mov    $0xf0105268,%eax
f010321f:	e8 39 fe ff ff       	call   f010305d <stab_binsearch>

	if (lfun <= rfun) {
f0103224:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103227:	83 c4 10             	add    $0x10,%esp
f010322a:	3b 75 d8             	cmp    -0x28(%ebp),%esi
f010322d:	7f 79                	jg     f01032a8 <debuginfo_eip+0x15b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010322f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103232:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103235:	c7 c2 68 52 10 f0    	mov    $0xf0105268,%edx
f010323b:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f010323e:	8b 11                	mov    (%ecx),%edx
f0103240:	c7 c0 7e d8 10 f0    	mov    $0xf010d87e,%eax
f0103246:	81 e8 c1 ba 10 f0    	sub    $0xf010bac1,%eax
f010324c:	39 c2                	cmp    %eax,%edx
f010324e:	73 09                	jae    f0103259 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103250:	81 c2 c1 ba 10 f0    	add    $0xf010bac1,%edx
f0103256:	89 57 08             	mov    %edx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103259:	8b 41 08             	mov    0x8(%ecx),%eax
f010325c:	89 47 10             	mov    %eax,0x10(%edi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010325f:	83 ec 08             	sub    $0x8,%esp
f0103262:	6a 3a                	push   $0x3a
f0103264:	ff 77 08             	pushl  0x8(%edi)
f0103267:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010326a:	e8 1a 09 00 00       	call   f0103b89 <strfind>
f010326f:	2b 47 08             	sub    0x8(%edi),%eax
f0103272:	89 47 0c             	mov    %eax,0xc(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103275:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103278:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010327b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010327e:	c7 c2 68 52 10 f0    	mov    $0xf0105268,%edx
f0103284:	8d 44 82 04          	lea    0x4(%edx,%eax,4),%eax
f0103288:	83 c4 10             	add    $0x10,%esp
f010328b:	eb 29                	jmp    f01032b6 <debuginfo_eip+0x169>
  	        panic("User address");
f010328d:	83 ec 04             	sub    $0x4,%esp
f0103290:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103293:	8d 83 52 dd fe ff    	lea    -0x122ae(%ebx),%eax
f0103299:	50                   	push   %eax
f010329a:	6a 7f                	push   $0x7f
f010329c:	8d 83 5f dd fe ff    	lea    -0x122a1(%ebx),%eax
f01032a2:	50                   	push   %eax
f01032a3:	e8 f1 cd ff ff       	call   f0100099 <_panic>
		info->eip_fn_addr = addr;
f01032a8:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f01032ab:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01032ae:	eb af                	jmp    f010325f <debuginfo_eip+0x112>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01032b0:	83 ee 01             	sub    $0x1,%esi
f01032b3:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f01032b6:	39 f3                	cmp    %esi,%ebx
f01032b8:	7f 3a                	jg     f01032f4 <debuginfo_eip+0x1a7>
	       && stabs[lline].n_type != N_SOL
f01032ba:	0f b6 10             	movzbl (%eax),%edx
f01032bd:	80 fa 84             	cmp    $0x84,%dl
f01032c0:	74 0b                	je     f01032cd <debuginfo_eip+0x180>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01032c2:	80 fa 64             	cmp    $0x64,%dl
f01032c5:	75 e9                	jne    f01032b0 <debuginfo_eip+0x163>
f01032c7:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f01032cb:	74 e3                	je     f01032b0 <debuginfo_eip+0x163>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01032cd:	8d 14 76             	lea    (%esi,%esi,2),%edx
f01032d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032d3:	c7 c0 68 52 10 f0    	mov    $0xf0105268,%eax
f01032d9:	8b 14 90             	mov    (%eax,%edx,4),%edx
f01032dc:	c7 c0 7e d8 10 f0    	mov    $0xf010d87e,%eax
f01032e2:	81 e8 c1 ba 10 f0    	sub    $0xf010bac1,%eax
f01032e8:	39 c2                	cmp    %eax,%edx
f01032ea:	73 08                	jae    f01032f4 <debuginfo_eip+0x1a7>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01032ec:	81 c2 c1 ba 10 f0    	add    $0xf010bac1,%edx
f01032f2:	89 17                	mov    %edx,(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01032f4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01032f7:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01032fa:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01032ff:	39 cb                	cmp    %ecx,%ebx
f0103301:	7d 4a                	jge    f010334d <debuginfo_eip+0x200>
		for (lline = lfun + 1;
f0103303:	8d 53 01             	lea    0x1(%ebx),%edx
f0103306:	8d 1c 5b             	lea    (%ebx,%ebx,2),%ebx
f0103309:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010330c:	c7 c0 68 52 10 f0    	mov    $0xf0105268,%eax
f0103312:	8d 44 98 10          	lea    0x10(%eax,%ebx,4),%eax
f0103316:	eb 07                	jmp    f010331f <debuginfo_eip+0x1d2>
			info->eip_fn_narg++;
f0103318:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f010331c:	83 c2 01             	add    $0x1,%edx
		for (lline = lfun + 1;
f010331f:	39 d1                	cmp    %edx,%ecx
f0103321:	74 25                	je     f0103348 <debuginfo_eip+0x1fb>
f0103323:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103326:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f010332a:	74 ec                	je     f0103318 <debuginfo_eip+0x1cb>
	return 0;
f010332c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103331:	eb 1a                	jmp    f010334d <debuginfo_eip+0x200>
		return -1;
f0103333:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103338:	eb 13                	jmp    f010334d <debuginfo_eip+0x200>
f010333a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010333f:	eb 0c                	jmp    f010334d <debuginfo_eip+0x200>
		return -1;
f0103341:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103346:	eb 05                	jmp    f010334d <debuginfo_eip+0x200>
	return 0;
f0103348:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010334d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103350:	5b                   	pop    %ebx
f0103351:	5e                   	pop    %esi
f0103352:	5f                   	pop    %edi
f0103353:	5d                   	pop    %ebp
f0103354:	c3                   	ret    

f0103355 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103355:	55                   	push   %ebp
f0103356:	89 e5                	mov    %esp,%ebp
f0103358:	57                   	push   %edi
f0103359:	56                   	push   %esi
f010335a:	53                   	push   %ebx
f010335b:	83 ec 2c             	sub    $0x2c,%esp
f010335e:	e8 57 fc ff ff       	call   f0102fba <__x86.get_pc_thunk.cx>
f0103363:	81 c1 a5 3f 01 00    	add    $0x13fa5,%ecx
f0103369:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010336c:	89 c7                	mov    %eax,%edi
f010336e:	89 d6                	mov    %edx,%esi
f0103370:	8b 45 08             	mov    0x8(%ebp),%eax
f0103373:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103376:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103379:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010337c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010337f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103384:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0103387:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f010338a:	39 d3                	cmp    %edx,%ebx
f010338c:	72 09                	jb     f0103397 <printnum+0x42>
f010338e:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103391:	0f 87 83 00 00 00    	ja     f010341a <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103397:	83 ec 0c             	sub    $0xc,%esp
f010339a:	ff 75 18             	pushl  0x18(%ebp)
f010339d:	8b 45 14             	mov    0x14(%ebp),%eax
f01033a0:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01033a3:	53                   	push   %ebx
f01033a4:	ff 75 10             	pushl  0x10(%ebp)
f01033a7:	83 ec 08             	sub    $0x8,%esp
f01033aa:	ff 75 dc             	pushl  -0x24(%ebp)
f01033ad:	ff 75 d8             	pushl  -0x28(%ebp)
f01033b0:	ff 75 d4             	pushl  -0x2c(%ebp)
f01033b3:	ff 75 d0             	pushl  -0x30(%ebp)
f01033b6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01033b9:	e8 f2 09 00 00       	call   f0103db0 <__udivdi3>
f01033be:	83 c4 18             	add    $0x18,%esp
f01033c1:	52                   	push   %edx
f01033c2:	50                   	push   %eax
f01033c3:	89 f2                	mov    %esi,%edx
f01033c5:	89 f8                	mov    %edi,%eax
f01033c7:	e8 89 ff ff ff       	call   f0103355 <printnum>
f01033cc:	83 c4 20             	add    $0x20,%esp
f01033cf:	eb 13                	jmp    f01033e4 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01033d1:	83 ec 08             	sub    $0x8,%esp
f01033d4:	56                   	push   %esi
f01033d5:	ff 75 18             	pushl  0x18(%ebp)
f01033d8:	ff d7                	call   *%edi
f01033da:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01033dd:	83 eb 01             	sub    $0x1,%ebx
f01033e0:	85 db                	test   %ebx,%ebx
f01033e2:	7f ed                	jg     f01033d1 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01033e4:	83 ec 08             	sub    $0x8,%esp
f01033e7:	56                   	push   %esi
f01033e8:	83 ec 04             	sub    $0x4,%esp
f01033eb:	ff 75 dc             	pushl  -0x24(%ebp)
f01033ee:	ff 75 d8             	pushl  -0x28(%ebp)
f01033f1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01033f4:	ff 75 d0             	pushl  -0x30(%ebp)
f01033f7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01033fa:	89 f3                	mov    %esi,%ebx
f01033fc:	e8 cf 0a 00 00       	call   f0103ed0 <__umoddi3>
f0103401:	83 c4 14             	add    $0x14,%esp
f0103404:	0f be 84 06 6d dd fe 	movsbl -0x12293(%esi,%eax,1),%eax
f010340b:	ff 
f010340c:	50                   	push   %eax
f010340d:	ff d7                	call   *%edi
}
f010340f:	83 c4 10             	add    $0x10,%esp
f0103412:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103415:	5b                   	pop    %ebx
f0103416:	5e                   	pop    %esi
f0103417:	5f                   	pop    %edi
f0103418:	5d                   	pop    %ebp
f0103419:	c3                   	ret    
f010341a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010341d:	eb be                	jmp    f01033dd <printnum+0x88>

f010341f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010341f:	55                   	push   %ebp
f0103420:	89 e5                	mov    %esp,%ebp
f0103422:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103425:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103429:	8b 10                	mov    (%eax),%edx
f010342b:	3b 50 04             	cmp    0x4(%eax),%edx
f010342e:	73 0a                	jae    f010343a <sprintputch+0x1b>
		*b->buf++ = ch;
f0103430:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103433:	89 08                	mov    %ecx,(%eax)
f0103435:	8b 45 08             	mov    0x8(%ebp),%eax
f0103438:	88 02                	mov    %al,(%edx)
}
f010343a:	5d                   	pop    %ebp
f010343b:	c3                   	ret    

f010343c <printfmt>:
{
f010343c:	55                   	push   %ebp
f010343d:	89 e5                	mov    %esp,%ebp
f010343f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0103442:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103445:	50                   	push   %eax
f0103446:	ff 75 10             	pushl  0x10(%ebp)
f0103449:	ff 75 0c             	pushl  0xc(%ebp)
f010344c:	ff 75 08             	pushl  0x8(%ebp)
f010344f:	e8 05 00 00 00       	call   f0103459 <vprintfmt>
}
f0103454:	83 c4 10             	add    $0x10,%esp
f0103457:	c9                   	leave  
f0103458:	c3                   	ret    

f0103459 <vprintfmt>:
{
f0103459:	55                   	push   %ebp
f010345a:	89 e5                	mov    %esp,%ebp
f010345c:	57                   	push   %edi
f010345d:	56                   	push   %esi
f010345e:	53                   	push   %ebx
f010345f:	83 ec 2c             	sub    $0x2c,%esp
f0103462:	e8 e8 cc ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0103467:	81 c3 a1 3e 01 00    	add    $0x13ea1,%ebx
f010346d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103470:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103473:	e9 8e 03 00 00       	jmp    f0103806 <.L35+0x48>
		padc = ' ';
f0103478:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f010347c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0103483:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f010348a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0103491:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103496:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103499:	8d 47 01             	lea    0x1(%edi),%eax
f010349c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010349f:	0f b6 17             	movzbl (%edi),%edx
f01034a2:	8d 42 dd             	lea    -0x23(%edx),%eax
f01034a5:	3c 55                	cmp    $0x55,%al
f01034a7:	0f 87 e1 03 00 00    	ja     f010388e <.L22>
f01034ad:	0f b6 c0             	movzbl %al,%eax
f01034b0:	89 d9                	mov    %ebx,%ecx
f01034b2:	03 8c 83 f8 dd fe ff 	add    -0x12208(%ebx,%eax,4),%ecx
f01034b9:	ff e1                	jmp    *%ecx

f01034bb <.L67>:
f01034bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f01034be:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f01034c2:	eb d5                	jmp    f0103499 <vprintfmt+0x40>

f01034c4 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f01034c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f01034c7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01034cb:	eb cc                	jmp    f0103499 <vprintfmt+0x40>

f01034cd <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f01034cd:	0f b6 d2             	movzbl %dl,%edx
f01034d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f01034d3:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f01034d8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01034db:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01034df:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01034e2:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01034e5:	83 f9 09             	cmp    $0x9,%ecx
f01034e8:	77 55                	ja     f010353f <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f01034ea:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f01034ed:	eb e9                	jmp    f01034d8 <.L29+0xb>

f01034ef <.L26>:
			precision = va_arg(ap, int);
f01034ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01034f2:	8b 00                	mov    (%eax),%eax
f01034f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01034f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01034fa:	8d 40 04             	lea    0x4(%eax),%eax
f01034fd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0103503:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103507:	79 90                	jns    f0103499 <vprintfmt+0x40>
				width = precision, precision = -1;
f0103509:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010350c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010350f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103516:	eb 81                	jmp    f0103499 <vprintfmt+0x40>

f0103518 <.L27>:
f0103518:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010351b:	85 c0                	test   %eax,%eax
f010351d:	ba 00 00 00 00       	mov    $0x0,%edx
f0103522:	0f 49 d0             	cmovns %eax,%edx
f0103525:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103528:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010352b:	e9 69 ff ff ff       	jmp    f0103499 <vprintfmt+0x40>

f0103530 <.L23>:
f0103530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0103533:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010353a:	e9 5a ff ff ff       	jmp    f0103499 <vprintfmt+0x40>
f010353f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103542:	eb bf                	jmp    f0103503 <.L26+0x14>

f0103544 <.L33>:
			lflag++;
f0103544:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103548:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f010354b:	e9 49 ff ff ff       	jmp    f0103499 <vprintfmt+0x40>

f0103550 <.L30>:
			putch(va_arg(ap, int), putdat);
f0103550:	8b 45 14             	mov    0x14(%ebp),%eax
f0103553:	8d 78 04             	lea    0x4(%eax),%edi
f0103556:	83 ec 08             	sub    $0x8,%esp
f0103559:	56                   	push   %esi
f010355a:	ff 30                	pushl  (%eax)
f010355c:	ff 55 08             	call   *0x8(%ebp)
			break;
f010355f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0103562:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0103565:	e9 99 02 00 00       	jmp    f0103803 <.L35+0x45>

f010356a <.L32>:
			err = va_arg(ap, int);
f010356a:	8b 45 14             	mov    0x14(%ebp),%eax
f010356d:	8d 78 04             	lea    0x4(%eax),%edi
f0103570:	8b 00                	mov    (%eax),%eax
f0103572:	99                   	cltd   
f0103573:	31 d0                	xor    %edx,%eax
f0103575:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103577:	83 f8 06             	cmp    $0x6,%eax
f010357a:	7f 27                	jg     f01035a3 <.L32+0x39>
f010357c:	8b 94 83 20 1d 00 00 	mov    0x1d20(%ebx,%eax,4),%edx
f0103583:	85 d2                	test   %edx,%edx
f0103585:	74 1c                	je     f01035a3 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f0103587:	52                   	push   %edx
f0103588:	8d 83 b8 d1 fe ff    	lea    -0x12e48(%ebx),%eax
f010358e:	50                   	push   %eax
f010358f:	56                   	push   %esi
f0103590:	ff 75 08             	pushl  0x8(%ebp)
f0103593:	e8 a4 fe ff ff       	call   f010343c <printfmt>
f0103598:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010359b:	89 7d 14             	mov    %edi,0x14(%ebp)
f010359e:	e9 60 02 00 00       	jmp    f0103803 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f01035a3:	50                   	push   %eax
f01035a4:	8d 83 85 dd fe ff    	lea    -0x1227b(%ebx),%eax
f01035aa:	50                   	push   %eax
f01035ab:	56                   	push   %esi
f01035ac:	ff 75 08             	pushl  0x8(%ebp)
f01035af:	e8 88 fe ff ff       	call   f010343c <printfmt>
f01035b4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01035b7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01035ba:	e9 44 02 00 00       	jmp    f0103803 <.L35+0x45>

f01035bf <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f01035bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01035c2:	83 c0 04             	add    $0x4,%eax
f01035c5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01035c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01035cb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01035cd:	85 ff                	test   %edi,%edi
f01035cf:	8d 83 7e dd fe ff    	lea    -0x12282(%ebx),%eax
f01035d5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01035d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01035dc:	0f 8e b5 00 00 00    	jle    f0103697 <.L36+0xd8>
f01035e2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01035e6:	75 08                	jne    f01035f0 <.L36+0x31>
f01035e8:	89 75 0c             	mov    %esi,0xc(%ebp)
f01035eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01035ee:	eb 6d                	jmp    f010365d <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f01035f0:	83 ec 08             	sub    $0x8,%esp
f01035f3:	ff 75 d0             	pushl  -0x30(%ebp)
f01035f6:	57                   	push   %edi
f01035f7:	e8 49 04 00 00       	call   f0103a45 <strnlen>
f01035fc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035ff:	29 c2                	sub    %eax,%edx
f0103601:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0103604:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103607:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010360b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010360e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103611:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103613:	eb 10                	jmp    f0103625 <.L36+0x66>
					putch(padc, putdat);
f0103615:	83 ec 08             	sub    $0x8,%esp
f0103618:	56                   	push   %esi
f0103619:	ff 75 e0             	pushl  -0x20(%ebp)
f010361c:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010361f:	83 ef 01             	sub    $0x1,%edi
f0103622:	83 c4 10             	add    $0x10,%esp
f0103625:	85 ff                	test   %edi,%edi
f0103627:	7f ec                	jg     f0103615 <.L36+0x56>
f0103629:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010362c:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010362f:	85 d2                	test   %edx,%edx
f0103631:	b8 00 00 00 00       	mov    $0x0,%eax
f0103636:	0f 49 c2             	cmovns %edx,%eax
f0103639:	29 c2                	sub    %eax,%edx
f010363b:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010363e:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103641:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103644:	eb 17                	jmp    f010365d <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f0103646:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010364a:	75 30                	jne    f010367c <.L36+0xbd>
					putch(ch, putdat);
f010364c:	83 ec 08             	sub    $0x8,%esp
f010364f:	ff 75 0c             	pushl  0xc(%ebp)
f0103652:	50                   	push   %eax
f0103653:	ff 55 08             	call   *0x8(%ebp)
f0103656:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103659:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f010365d:	83 c7 01             	add    $0x1,%edi
f0103660:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0103664:	0f be c2             	movsbl %dl,%eax
f0103667:	85 c0                	test   %eax,%eax
f0103669:	74 52                	je     f01036bd <.L36+0xfe>
f010366b:	85 f6                	test   %esi,%esi
f010366d:	78 d7                	js     f0103646 <.L36+0x87>
f010366f:	83 ee 01             	sub    $0x1,%esi
f0103672:	79 d2                	jns    f0103646 <.L36+0x87>
f0103674:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103677:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010367a:	eb 32                	jmp    f01036ae <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f010367c:	0f be d2             	movsbl %dl,%edx
f010367f:	83 ea 20             	sub    $0x20,%edx
f0103682:	83 fa 5e             	cmp    $0x5e,%edx
f0103685:	76 c5                	jbe    f010364c <.L36+0x8d>
					putch('?', putdat);
f0103687:	83 ec 08             	sub    $0x8,%esp
f010368a:	ff 75 0c             	pushl  0xc(%ebp)
f010368d:	6a 3f                	push   $0x3f
f010368f:	ff 55 08             	call   *0x8(%ebp)
f0103692:	83 c4 10             	add    $0x10,%esp
f0103695:	eb c2                	jmp    f0103659 <.L36+0x9a>
f0103697:	89 75 0c             	mov    %esi,0xc(%ebp)
f010369a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010369d:	eb be                	jmp    f010365d <.L36+0x9e>
				putch(' ', putdat);
f010369f:	83 ec 08             	sub    $0x8,%esp
f01036a2:	56                   	push   %esi
f01036a3:	6a 20                	push   $0x20
f01036a5:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f01036a8:	83 ef 01             	sub    $0x1,%edi
f01036ab:	83 c4 10             	add    $0x10,%esp
f01036ae:	85 ff                	test   %edi,%edi
f01036b0:	7f ed                	jg     f010369f <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f01036b2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01036b5:	89 45 14             	mov    %eax,0x14(%ebp)
f01036b8:	e9 46 01 00 00       	jmp    f0103803 <.L35+0x45>
f01036bd:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01036c0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01036c3:	eb e9                	jmp    f01036ae <.L36+0xef>

f01036c5 <.L31>:
f01036c5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
f01036c8:	83 f9 01             	cmp    $0x1,%ecx
f01036cb:	7e 40                	jle    f010370d <.L31+0x48>
		return va_arg(*ap, long long);
f01036cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01036d0:	8b 50 04             	mov    0x4(%eax),%edx
f01036d3:	8b 00                	mov    (%eax),%eax
f01036d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01036d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01036db:	8b 45 14             	mov    0x14(%ebp),%eax
f01036de:	8d 40 08             	lea    0x8(%eax),%eax
f01036e1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01036e4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01036e8:	79 55                	jns    f010373f <.L31+0x7a>
				putch('-', putdat);
f01036ea:	83 ec 08             	sub    $0x8,%esp
f01036ed:	56                   	push   %esi
f01036ee:	6a 2d                	push   $0x2d
f01036f0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01036f3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01036f6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01036f9:	f7 da                	neg    %edx
f01036fb:	83 d1 00             	adc    $0x0,%ecx
f01036fe:	f7 d9                	neg    %ecx
f0103700:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0103703:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103708:	e9 db 00 00 00       	jmp    f01037e8 <.L35+0x2a>
	else if (lflag)
f010370d:	85 c9                	test   %ecx,%ecx
f010370f:	75 17                	jne    f0103728 <.L31+0x63>
		return va_arg(*ap, int);
f0103711:	8b 45 14             	mov    0x14(%ebp),%eax
f0103714:	8b 00                	mov    (%eax),%eax
f0103716:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103719:	99                   	cltd   
f010371a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010371d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103720:	8d 40 04             	lea    0x4(%eax),%eax
f0103723:	89 45 14             	mov    %eax,0x14(%ebp)
f0103726:	eb bc                	jmp    f01036e4 <.L31+0x1f>
		return va_arg(*ap, long);
f0103728:	8b 45 14             	mov    0x14(%ebp),%eax
f010372b:	8b 00                	mov    (%eax),%eax
f010372d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103730:	99                   	cltd   
f0103731:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103734:	8b 45 14             	mov    0x14(%ebp),%eax
f0103737:	8d 40 04             	lea    0x4(%eax),%eax
f010373a:	89 45 14             	mov    %eax,0x14(%ebp)
f010373d:	eb a5                	jmp    f01036e4 <.L31+0x1f>
			num = getint(&ap, lflag);
f010373f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103742:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0103745:	b8 0a 00 00 00       	mov    $0xa,%eax
f010374a:	e9 99 00 00 00       	jmp    f01037e8 <.L35+0x2a>

f010374f <.L37>:
f010374f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
f0103752:	83 f9 01             	cmp    $0x1,%ecx
f0103755:	7e 15                	jle    f010376c <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
f0103757:	8b 45 14             	mov    0x14(%ebp),%eax
f010375a:	8b 10                	mov    (%eax),%edx
f010375c:	8b 48 04             	mov    0x4(%eax),%ecx
f010375f:	8d 40 08             	lea    0x8(%eax),%eax
f0103762:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103765:	b8 0a 00 00 00       	mov    $0xa,%eax
f010376a:	eb 7c                	jmp    f01037e8 <.L35+0x2a>
	else if (lflag)
f010376c:	85 c9                	test   %ecx,%ecx
f010376e:	75 17                	jne    f0103787 <.L37+0x38>
		return va_arg(*ap, unsigned int);
f0103770:	8b 45 14             	mov    0x14(%ebp),%eax
f0103773:	8b 10                	mov    (%eax),%edx
f0103775:	b9 00 00 00 00       	mov    $0x0,%ecx
f010377a:	8d 40 04             	lea    0x4(%eax),%eax
f010377d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103780:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103785:	eb 61                	jmp    f01037e8 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0103787:	8b 45 14             	mov    0x14(%ebp),%eax
f010378a:	8b 10                	mov    (%eax),%edx
f010378c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103791:	8d 40 04             	lea    0x4(%eax),%eax
f0103794:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103797:	b8 0a 00 00 00       	mov    $0xa,%eax
f010379c:	eb 4a                	jmp    f01037e8 <.L35+0x2a>

f010379e <.L34>:
			putch('X', putdat);
f010379e:	83 ec 08             	sub    $0x8,%esp
f01037a1:	56                   	push   %esi
f01037a2:	6a 58                	push   $0x58
f01037a4:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01037a7:	83 c4 08             	add    $0x8,%esp
f01037aa:	56                   	push   %esi
f01037ab:	6a 58                	push   $0x58
f01037ad:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01037b0:	83 c4 08             	add    $0x8,%esp
f01037b3:	56                   	push   %esi
f01037b4:	6a 58                	push   $0x58
f01037b6:	ff 55 08             	call   *0x8(%ebp)
			break;
f01037b9:	83 c4 10             	add    $0x10,%esp
f01037bc:	eb 45                	jmp    f0103803 <.L35+0x45>

f01037be <.L35>:
			putch('0', putdat);
f01037be:	83 ec 08             	sub    $0x8,%esp
f01037c1:	56                   	push   %esi
f01037c2:	6a 30                	push   $0x30
f01037c4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01037c7:	83 c4 08             	add    $0x8,%esp
f01037ca:	56                   	push   %esi
f01037cb:	6a 78                	push   $0x78
f01037cd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f01037d0:	8b 45 14             	mov    0x14(%ebp),%eax
f01037d3:	8b 10                	mov    (%eax),%edx
f01037d5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01037da:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01037dd:	8d 40 04             	lea    0x4(%eax),%eax
f01037e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01037e3:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01037e8:	83 ec 0c             	sub    $0xc,%esp
f01037eb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01037ef:	57                   	push   %edi
f01037f0:	ff 75 e0             	pushl  -0x20(%ebp)
f01037f3:	50                   	push   %eax
f01037f4:	51                   	push   %ecx
f01037f5:	52                   	push   %edx
f01037f6:	89 f2                	mov    %esi,%edx
f01037f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01037fb:	e8 55 fb ff ff       	call   f0103355 <printnum>
			break;
f0103800:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0103803:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103806:	83 c7 01             	add    $0x1,%edi
f0103809:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010380d:	83 f8 25             	cmp    $0x25,%eax
f0103810:	0f 84 62 fc ff ff    	je     f0103478 <vprintfmt+0x1f>
			if (ch == '\0')
f0103816:	85 c0                	test   %eax,%eax
f0103818:	0f 84 91 00 00 00    	je     f01038af <.L22+0x21>
			putch(ch, putdat);
f010381e:	83 ec 08             	sub    $0x8,%esp
f0103821:	56                   	push   %esi
f0103822:	50                   	push   %eax
f0103823:	ff 55 08             	call   *0x8(%ebp)
f0103826:	83 c4 10             	add    $0x10,%esp
f0103829:	eb db                	jmp    f0103806 <.L35+0x48>

f010382b <.L38>:
f010382b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
f010382e:	83 f9 01             	cmp    $0x1,%ecx
f0103831:	7e 15                	jle    f0103848 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f0103833:	8b 45 14             	mov    0x14(%ebp),%eax
f0103836:	8b 10                	mov    (%eax),%edx
f0103838:	8b 48 04             	mov    0x4(%eax),%ecx
f010383b:	8d 40 08             	lea    0x8(%eax),%eax
f010383e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103841:	b8 10 00 00 00       	mov    $0x10,%eax
f0103846:	eb a0                	jmp    f01037e8 <.L35+0x2a>
	else if (lflag)
f0103848:	85 c9                	test   %ecx,%ecx
f010384a:	75 17                	jne    f0103863 <.L38+0x38>
		return va_arg(*ap, unsigned int);
f010384c:	8b 45 14             	mov    0x14(%ebp),%eax
f010384f:	8b 10                	mov    (%eax),%edx
f0103851:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103856:	8d 40 04             	lea    0x4(%eax),%eax
f0103859:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010385c:	b8 10 00 00 00       	mov    $0x10,%eax
f0103861:	eb 85                	jmp    f01037e8 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0103863:	8b 45 14             	mov    0x14(%ebp),%eax
f0103866:	8b 10                	mov    (%eax),%edx
f0103868:	b9 00 00 00 00       	mov    $0x0,%ecx
f010386d:	8d 40 04             	lea    0x4(%eax),%eax
f0103870:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103873:	b8 10 00 00 00       	mov    $0x10,%eax
f0103878:	e9 6b ff ff ff       	jmp    f01037e8 <.L35+0x2a>

f010387d <.L25>:
			putch(ch, putdat);
f010387d:	83 ec 08             	sub    $0x8,%esp
f0103880:	56                   	push   %esi
f0103881:	6a 25                	push   $0x25
f0103883:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103886:	83 c4 10             	add    $0x10,%esp
f0103889:	e9 75 ff ff ff       	jmp    f0103803 <.L35+0x45>

f010388e <.L22>:
			putch('%', putdat);
f010388e:	83 ec 08             	sub    $0x8,%esp
f0103891:	56                   	push   %esi
f0103892:	6a 25                	push   $0x25
f0103894:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103897:	83 c4 10             	add    $0x10,%esp
f010389a:	89 f8                	mov    %edi,%eax
f010389c:	eb 03                	jmp    f01038a1 <.L22+0x13>
f010389e:	83 e8 01             	sub    $0x1,%eax
f01038a1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01038a5:	75 f7                	jne    f010389e <.L22+0x10>
f01038a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01038aa:	e9 54 ff ff ff       	jmp    f0103803 <.L35+0x45>
}
f01038af:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01038b2:	5b                   	pop    %ebx
f01038b3:	5e                   	pop    %esi
f01038b4:	5f                   	pop    %edi
f01038b5:	5d                   	pop    %ebp
f01038b6:	c3                   	ret    

f01038b7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01038b7:	55                   	push   %ebp
f01038b8:	89 e5                	mov    %esp,%ebp
f01038ba:	53                   	push   %ebx
f01038bb:	83 ec 14             	sub    $0x14,%esp
f01038be:	e8 8c c8 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01038c3:	81 c3 45 3a 01 00    	add    $0x13a45,%ebx
f01038c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01038cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01038cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01038d2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01038d6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01038d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01038e0:	85 c0                	test   %eax,%eax
f01038e2:	74 2b                	je     f010390f <vsnprintf+0x58>
f01038e4:	85 d2                	test   %edx,%edx
f01038e6:	7e 27                	jle    f010390f <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01038e8:	ff 75 14             	pushl  0x14(%ebp)
f01038eb:	ff 75 10             	pushl  0x10(%ebp)
f01038ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01038f1:	50                   	push   %eax
f01038f2:	8d 83 17 c1 fe ff    	lea    -0x13ee9(%ebx),%eax
f01038f8:	50                   	push   %eax
f01038f9:	e8 5b fb ff ff       	call   f0103459 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01038fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103901:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103904:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103907:	83 c4 10             	add    $0x10,%esp
}
f010390a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010390d:	c9                   	leave  
f010390e:	c3                   	ret    
		return -E_INVAL;
f010390f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103914:	eb f4                	jmp    f010390a <vsnprintf+0x53>

f0103916 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103916:	55                   	push   %ebp
f0103917:	89 e5                	mov    %esp,%ebp
f0103919:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010391c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010391f:	50                   	push   %eax
f0103920:	ff 75 10             	pushl  0x10(%ebp)
f0103923:	ff 75 0c             	pushl  0xc(%ebp)
f0103926:	ff 75 08             	pushl  0x8(%ebp)
f0103929:	e8 89 ff ff ff       	call   f01038b7 <vsnprintf>
	va_end(ap);

	return rc;
}
f010392e:	c9                   	leave  
f010392f:	c3                   	ret    

f0103930 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103930:	55                   	push   %ebp
f0103931:	89 e5                	mov    %esp,%ebp
f0103933:	57                   	push   %edi
f0103934:	56                   	push   %esi
f0103935:	53                   	push   %ebx
f0103936:	83 ec 1c             	sub    $0x1c,%esp
f0103939:	e8 11 c8 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010393e:	81 c3 ca 39 01 00    	add    $0x139ca,%ebx
f0103944:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103947:	85 c0                	test   %eax,%eax
f0103949:	74 13                	je     f010395e <readline+0x2e>
		cprintf("%s", prompt);
f010394b:	83 ec 08             	sub    $0x8,%esp
f010394e:	50                   	push   %eax
f010394f:	8d 83 b8 d1 fe ff    	lea    -0x12e48(%ebx),%eax
f0103955:	50                   	push   %eax
f0103956:	e8 ee f6 ff ff       	call   f0103049 <cprintf>
f010395b:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010395e:	83 ec 0c             	sub    $0xc,%esp
f0103961:	6a 00                	push   $0x0
f0103963:	e8 7f cd ff ff       	call   f01006e7 <iscons>
f0103968:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010396b:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010396e:	bf 00 00 00 00       	mov    $0x0,%edi
f0103973:	eb 46                	jmp    f01039bb <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0103975:	83 ec 08             	sub    $0x8,%esp
f0103978:	50                   	push   %eax
f0103979:	8d 83 50 df fe ff    	lea    -0x120b0(%ebx),%eax
f010397f:	50                   	push   %eax
f0103980:	e8 c4 f6 ff ff       	call   f0103049 <cprintf>
			return NULL;
f0103985:	83 c4 10             	add    $0x10,%esp
f0103988:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010398d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103990:	5b                   	pop    %ebx
f0103991:	5e                   	pop    %esi
f0103992:	5f                   	pop    %edi
f0103993:	5d                   	pop    %ebp
f0103994:	c3                   	ret    
			if (echoing)
f0103995:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103999:	75 05                	jne    f01039a0 <readline+0x70>
			i--;
f010399b:	83 ef 01             	sub    $0x1,%edi
f010399e:	eb 1b                	jmp    f01039bb <readline+0x8b>
				cputchar('\b');
f01039a0:	83 ec 0c             	sub    $0xc,%esp
f01039a3:	6a 08                	push   $0x8
f01039a5:	e8 1c cd ff ff       	call   f01006c6 <cputchar>
f01039aa:	83 c4 10             	add    $0x10,%esp
f01039ad:	eb ec                	jmp    f010399b <readline+0x6b>
			buf[i++] = c;
f01039af:	89 f0                	mov    %esi,%eax
f01039b1:	88 84 3b b8 1f 00 00 	mov    %al,0x1fb8(%ebx,%edi,1)
f01039b8:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01039bb:	e8 16 cd ff ff       	call   f01006d6 <getchar>
f01039c0:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01039c2:	85 c0                	test   %eax,%eax
f01039c4:	78 af                	js     f0103975 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01039c6:	83 f8 08             	cmp    $0x8,%eax
f01039c9:	0f 94 c2             	sete   %dl
f01039cc:	83 f8 7f             	cmp    $0x7f,%eax
f01039cf:	0f 94 c0             	sete   %al
f01039d2:	08 c2                	or     %al,%dl
f01039d4:	74 04                	je     f01039da <readline+0xaa>
f01039d6:	85 ff                	test   %edi,%edi
f01039d8:	7f bb                	jg     f0103995 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01039da:	83 fe 1f             	cmp    $0x1f,%esi
f01039dd:	7e 1c                	jle    f01039fb <readline+0xcb>
f01039df:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01039e5:	7f 14                	jg     f01039fb <readline+0xcb>
			if (echoing)
f01039e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01039eb:	74 c2                	je     f01039af <readline+0x7f>
				cputchar(c);
f01039ed:	83 ec 0c             	sub    $0xc,%esp
f01039f0:	56                   	push   %esi
f01039f1:	e8 d0 cc ff ff       	call   f01006c6 <cputchar>
f01039f6:	83 c4 10             	add    $0x10,%esp
f01039f9:	eb b4                	jmp    f01039af <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f01039fb:	83 fe 0a             	cmp    $0xa,%esi
f01039fe:	74 05                	je     f0103a05 <readline+0xd5>
f0103a00:	83 fe 0d             	cmp    $0xd,%esi
f0103a03:	75 b6                	jne    f01039bb <readline+0x8b>
			if (echoing)
f0103a05:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103a09:	75 13                	jne    f0103a1e <readline+0xee>
			buf[i] = 0;
f0103a0b:	c6 84 3b b8 1f 00 00 	movb   $0x0,0x1fb8(%ebx,%edi,1)
f0103a12:	00 
			return buf;
f0103a13:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f0103a19:	e9 6f ff ff ff       	jmp    f010398d <readline+0x5d>
				cputchar('\n');
f0103a1e:	83 ec 0c             	sub    $0xc,%esp
f0103a21:	6a 0a                	push   $0xa
f0103a23:	e8 9e cc ff ff       	call   f01006c6 <cputchar>
f0103a28:	83 c4 10             	add    $0x10,%esp
f0103a2b:	eb de                	jmp    f0103a0b <readline+0xdb>

f0103a2d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103a2d:	55                   	push   %ebp
f0103a2e:	89 e5                	mov    %esp,%ebp
f0103a30:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103a33:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a38:	eb 03                	jmp    f0103a3d <strlen+0x10>
		n++;
f0103a3a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0103a3d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103a41:	75 f7                	jne    f0103a3a <strlen+0xd>
	return n;
}
f0103a43:	5d                   	pop    %ebp
f0103a44:	c3                   	ret    

f0103a45 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103a45:	55                   	push   %ebp
f0103a46:	89 e5                	mov    %esp,%ebp
f0103a48:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103a4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a53:	eb 03                	jmp    f0103a58 <strnlen+0x13>
		n++;
f0103a55:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103a58:	39 d0                	cmp    %edx,%eax
f0103a5a:	74 06                	je     f0103a62 <strnlen+0x1d>
f0103a5c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103a60:	75 f3                	jne    f0103a55 <strnlen+0x10>
	return n;
}
f0103a62:	5d                   	pop    %ebp
f0103a63:	c3                   	ret    

f0103a64 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103a64:	55                   	push   %ebp
f0103a65:	89 e5                	mov    %esp,%ebp
f0103a67:	53                   	push   %ebx
f0103a68:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103a6e:	89 c2                	mov    %eax,%edx
f0103a70:	83 c1 01             	add    $0x1,%ecx
f0103a73:	83 c2 01             	add    $0x1,%edx
f0103a76:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103a7a:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103a7d:	84 db                	test   %bl,%bl
f0103a7f:	75 ef                	jne    f0103a70 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103a81:	5b                   	pop    %ebx
f0103a82:	5d                   	pop    %ebp
f0103a83:	c3                   	ret    

f0103a84 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103a84:	55                   	push   %ebp
f0103a85:	89 e5                	mov    %esp,%ebp
f0103a87:	53                   	push   %ebx
f0103a88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103a8b:	53                   	push   %ebx
f0103a8c:	e8 9c ff ff ff       	call   f0103a2d <strlen>
f0103a91:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103a94:	ff 75 0c             	pushl  0xc(%ebp)
f0103a97:	01 d8                	add    %ebx,%eax
f0103a99:	50                   	push   %eax
f0103a9a:	e8 c5 ff ff ff       	call   f0103a64 <strcpy>
	return dst;
}
f0103a9f:	89 d8                	mov    %ebx,%eax
f0103aa1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103aa4:	c9                   	leave  
f0103aa5:	c3                   	ret    

f0103aa6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103aa6:	55                   	push   %ebp
f0103aa7:	89 e5                	mov    %esp,%ebp
f0103aa9:	56                   	push   %esi
f0103aaa:	53                   	push   %ebx
f0103aab:	8b 75 08             	mov    0x8(%ebp),%esi
f0103aae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103ab1:	89 f3                	mov    %esi,%ebx
f0103ab3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103ab6:	89 f2                	mov    %esi,%edx
f0103ab8:	eb 0f                	jmp    f0103ac9 <strncpy+0x23>
		*dst++ = *src;
f0103aba:	83 c2 01             	add    $0x1,%edx
f0103abd:	0f b6 01             	movzbl (%ecx),%eax
f0103ac0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103ac3:	80 39 01             	cmpb   $0x1,(%ecx)
f0103ac6:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0103ac9:	39 da                	cmp    %ebx,%edx
f0103acb:	75 ed                	jne    f0103aba <strncpy+0x14>
	}
	return ret;
}
f0103acd:	89 f0                	mov    %esi,%eax
f0103acf:	5b                   	pop    %ebx
f0103ad0:	5e                   	pop    %esi
f0103ad1:	5d                   	pop    %ebp
f0103ad2:	c3                   	ret    

f0103ad3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103ad3:	55                   	push   %ebp
f0103ad4:	89 e5                	mov    %esp,%ebp
f0103ad6:	56                   	push   %esi
f0103ad7:	53                   	push   %ebx
f0103ad8:	8b 75 08             	mov    0x8(%ebp),%esi
f0103adb:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103ae1:	89 f0                	mov    %esi,%eax
f0103ae3:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103ae7:	85 c9                	test   %ecx,%ecx
f0103ae9:	75 0b                	jne    f0103af6 <strlcpy+0x23>
f0103aeb:	eb 17                	jmp    f0103b04 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103aed:	83 c2 01             	add    $0x1,%edx
f0103af0:	83 c0 01             	add    $0x1,%eax
f0103af3:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0103af6:	39 d8                	cmp    %ebx,%eax
f0103af8:	74 07                	je     f0103b01 <strlcpy+0x2e>
f0103afa:	0f b6 0a             	movzbl (%edx),%ecx
f0103afd:	84 c9                	test   %cl,%cl
f0103aff:	75 ec                	jne    f0103aed <strlcpy+0x1a>
		*dst = '\0';
f0103b01:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103b04:	29 f0                	sub    %esi,%eax
}
f0103b06:	5b                   	pop    %ebx
f0103b07:	5e                   	pop    %esi
f0103b08:	5d                   	pop    %ebp
f0103b09:	c3                   	ret    

f0103b0a <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103b0a:	55                   	push   %ebp
f0103b0b:	89 e5                	mov    %esp,%ebp
f0103b0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103b10:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103b13:	eb 06                	jmp    f0103b1b <strcmp+0x11>
		p++, q++;
f0103b15:	83 c1 01             	add    $0x1,%ecx
f0103b18:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0103b1b:	0f b6 01             	movzbl (%ecx),%eax
f0103b1e:	84 c0                	test   %al,%al
f0103b20:	74 04                	je     f0103b26 <strcmp+0x1c>
f0103b22:	3a 02                	cmp    (%edx),%al
f0103b24:	74 ef                	je     f0103b15 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103b26:	0f b6 c0             	movzbl %al,%eax
f0103b29:	0f b6 12             	movzbl (%edx),%edx
f0103b2c:	29 d0                	sub    %edx,%eax
}
f0103b2e:	5d                   	pop    %ebp
f0103b2f:	c3                   	ret    

f0103b30 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103b30:	55                   	push   %ebp
f0103b31:	89 e5                	mov    %esp,%ebp
f0103b33:	53                   	push   %ebx
f0103b34:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b37:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b3a:	89 c3                	mov    %eax,%ebx
f0103b3c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103b3f:	eb 06                	jmp    f0103b47 <strncmp+0x17>
		n--, p++, q++;
f0103b41:	83 c0 01             	add    $0x1,%eax
f0103b44:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103b47:	39 d8                	cmp    %ebx,%eax
f0103b49:	74 16                	je     f0103b61 <strncmp+0x31>
f0103b4b:	0f b6 08             	movzbl (%eax),%ecx
f0103b4e:	84 c9                	test   %cl,%cl
f0103b50:	74 04                	je     f0103b56 <strncmp+0x26>
f0103b52:	3a 0a                	cmp    (%edx),%cl
f0103b54:	74 eb                	je     f0103b41 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103b56:	0f b6 00             	movzbl (%eax),%eax
f0103b59:	0f b6 12             	movzbl (%edx),%edx
f0103b5c:	29 d0                	sub    %edx,%eax
}
f0103b5e:	5b                   	pop    %ebx
f0103b5f:	5d                   	pop    %ebp
f0103b60:	c3                   	ret    
		return 0;
f0103b61:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b66:	eb f6                	jmp    f0103b5e <strncmp+0x2e>

f0103b68 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103b68:	55                   	push   %ebp
f0103b69:	89 e5                	mov    %esp,%ebp
f0103b6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b6e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103b72:	0f b6 10             	movzbl (%eax),%edx
f0103b75:	84 d2                	test   %dl,%dl
f0103b77:	74 09                	je     f0103b82 <strchr+0x1a>
		if (*s == c)
f0103b79:	38 ca                	cmp    %cl,%dl
f0103b7b:	74 0a                	je     f0103b87 <strchr+0x1f>
	for (; *s; s++)
f0103b7d:	83 c0 01             	add    $0x1,%eax
f0103b80:	eb f0                	jmp    f0103b72 <strchr+0xa>
			return (char *) s;
	return 0;
f0103b82:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103b87:	5d                   	pop    %ebp
f0103b88:	c3                   	ret    

f0103b89 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103b89:	55                   	push   %ebp
f0103b8a:	89 e5                	mov    %esp,%ebp
f0103b8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b8f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103b93:	eb 03                	jmp    f0103b98 <strfind+0xf>
f0103b95:	83 c0 01             	add    $0x1,%eax
f0103b98:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103b9b:	38 ca                	cmp    %cl,%dl
f0103b9d:	74 04                	je     f0103ba3 <strfind+0x1a>
f0103b9f:	84 d2                	test   %dl,%dl
f0103ba1:	75 f2                	jne    f0103b95 <strfind+0xc>
			break;
	return (char *) s;
}
f0103ba3:	5d                   	pop    %ebp
f0103ba4:	c3                   	ret    

f0103ba5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103ba5:	55                   	push   %ebp
f0103ba6:	89 e5                	mov    %esp,%ebp
f0103ba8:	57                   	push   %edi
f0103ba9:	56                   	push   %esi
f0103baa:	53                   	push   %ebx
f0103bab:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103bae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103bb1:	85 c9                	test   %ecx,%ecx
f0103bb3:	74 13                	je     f0103bc8 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103bb5:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103bbb:	75 05                	jne    f0103bc2 <memset+0x1d>
f0103bbd:	f6 c1 03             	test   $0x3,%cl
f0103bc0:	74 0d                	je     f0103bcf <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bc5:	fc                   	cld    
f0103bc6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103bc8:	89 f8                	mov    %edi,%eax
f0103bca:	5b                   	pop    %ebx
f0103bcb:	5e                   	pop    %esi
f0103bcc:	5f                   	pop    %edi
f0103bcd:	5d                   	pop    %ebp
f0103bce:	c3                   	ret    
		c &= 0xFF;
f0103bcf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103bd3:	89 d3                	mov    %edx,%ebx
f0103bd5:	c1 e3 08             	shl    $0x8,%ebx
f0103bd8:	89 d0                	mov    %edx,%eax
f0103bda:	c1 e0 18             	shl    $0x18,%eax
f0103bdd:	89 d6                	mov    %edx,%esi
f0103bdf:	c1 e6 10             	shl    $0x10,%esi
f0103be2:	09 f0                	or     %esi,%eax
f0103be4:	09 c2                	or     %eax,%edx
f0103be6:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0103be8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103beb:	89 d0                	mov    %edx,%eax
f0103bed:	fc                   	cld    
f0103bee:	f3 ab                	rep stos %eax,%es:(%edi)
f0103bf0:	eb d6                	jmp    f0103bc8 <memset+0x23>

f0103bf2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103bf2:	55                   	push   %ebp
f0103bf3:	89 e5                	mov    %esp,%ebp
f0103bf5:	57                   	push   %edi
f0103bf6:	56                   	push   %esi
f0103bf7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bfa:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103bfd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103c00:	39 c6                	cmp    %eax,%esi
f0103c02:	73 35                	jae    f0103c39 <memmove+0x47>
f0103c04:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103c07:	39 c2                	cmp    %eax,%edx
f0103c09:	76 2e                	jbe    f0103c39 <memmove+0x47>
		s += n;
		d += n;
f0103c0b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103c0e:	89 d6                	mov    %edx,%esi
f0103c10:	09 fe                	or     %edi,%esi
f0103c12:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103c18:	74 0c                	je     f0103c26 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103c1a:	83 ef 01             	sub    $0x1,%edi
f0103c1d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103c20:	fd                   	std    
f0103c21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103c23:	fc                   	cld    
f0103c24:	eb 21                	jmp    f0103c47 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103c26:	f6 c1 03             	test   $0x3,%cl
f0103c29:	75 ef                	jne    f0103c1a <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103c2b:	83 ef 04             	sub    $0x4,%edi
f0103c2e:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103c31:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0103c34:	fd                   	std    
f0103c35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103c37:	eb ea                	jmp    f0103c23 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103c39:	89 f2                	mov    %esi,%edx
f0103c3b:	09 c2                	or     %eax,%edx
f0103c3d:	f6 c2 03             	test   $0x3,%dl
f0103c40:	74 09                	je     f0103c4b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103c42:	89 c7                	mov    %eax,%edi
f0103c44:	fc                   	cld    
f0103c45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103c47:	5e                   	pop    %esi
f0103c48:	5f                   	pop    %edi
f0103c49:	5d                   	pop    %ebp
f0103c4a:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103c4b:	f6 c1 03             	test   $0x3,%cl
f0103c4e:	75 f2                	jne    f0103c42 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103c50:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0103c53:	89 c7                	mov    %eax,%edi
f0103c55:	fc                   	cld    
f0103c56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103c58:	eb ed                	jmp    f0103c47 <memmove+0x55>

f0103c5a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103c5a:	55                   	push   %ebp
f0103c5b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103c5d:	ff 75 10             	pushl  0x10(%ebp)
f0103c60:	ff 75 0c             	pushl  0xc(%ebp)
f0103c63:	ff 75 08             	pushl  0x8(%ebp)
f0103c66:	e8 87 ff ff ff       	call   f0103bf2 <memmove>
}
f0103c6b:	c9                   	leave  
f0103c6c:	c3                   	ret    

f0103c6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103c6d:	55                   	push   %ebp
f0103c6e:	89 e5                	mov    %esp,%ebp
f0103c70:	56                   	push   %esi
f0103c71:	53                   	push   %ebx
f0103c72:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c75:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103c78:	89 c6                	mov    %eax,%esi
f0103c7a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103c7d:	39 f0                	cmp    %esi,%eax
f0103c7f:	74 1c                	je     f0103c9d <memcmp+0x30>
		if (*s1 != *s2)
f0103c81:	0f b6 08             	movzbl (%eax),%ecx
f0103c84:	0f b6 1a             	movzbl (%edx),%ebx
f0103c87:	38 d9                	cmp    %bl,%cl
f0103c89:	75 08                	jne    f0103c93 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103c8b:	83 c0 01             	add    $0x1,%eax
f0103c8e:	83 c2 01             	add    $0x1,%edx
f0103c91:	eb ea                	jmp    f0103c7d <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0103c93:	0f b6 c1             	movzbl %cl,%eax
f0103c96:	0f b6 db             	movzbl %bl,%ebx
f0103c99:	29 d8                	sub    %ebx,%eax
f0103c9b:	eb 05                	jmp    f0103ca2 <memcmp+0x35>
	}

	return 0;
f0103c9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103ca2:	5b                   	pop    %ebx
f0103ca3:	5e                   	pop    %esi
f0103ca4:	5d                   	pop    %ebp
f0103ca5:	c3                   	ret    

f0103ca6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103ca6:	55                   	push   %ebp
f0103ca7:	89 e5                	mov    %esp,%ebp
f0103ca9:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103caf:	89 c2                	mov    %eax,%edx
f0103cb1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103cb4:	39 d0                	cmp    %edx,%eax
f0103cb6:	73 09                	jae    f0103cc1 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103cb8:	38 08                	cmp    %cl,(%eax)
f0103cba:	74 05                	je     f0103cc1 <memfind+0x1b>
	for (; s < ends; s++)
f0103cbc:	83 c0 01             	add    $0x1,%eax
f0103cbf:	eb f3                	jmp    f0103cb4 <memfind+0xe>
			break;
	return (void *) s;
}
f0103cc1:	5d                   	pop    %ebp
f0103cc2:	c3                   	ret    

f0103cc3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103cc3:	55                   	push   %ebp
f0103cc4:	89 e5                	mov    %esp,%ebp
f0103cc6:	57                   	push   %edi
f0103cc7:	56                   	push   %esi
f0103cc8:	53                   	push   %ebx
f0103cc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103ccc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103ccf:	eb 03                	jmp    f0103cd4 <strtol+0x11>
		s++;
f0103cd1:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0103cd4:	0f b6 01             	movzbl (%ecx),%eax
f0103cd7:	3c 20                	cmp    $0x20,%al
f0103cd9:	74 f6                	je     f0103cd1 <strtol+0xe>
f0103cdb:	3c 09                	cmp    $0x9,%al
f0103cdd:	74 f2                	je     f0103cd1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0103cdf:	3c 2b                	cmp    $0x2b,%al
f0103ce1:	74 2e                	je     f0103d11 <strtol+0x4e>
	int neg = 0;
f0103ce3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0103ce8:	3c 2d                	cmp    $0x2d,%al
f0103cea:	74 2f                	je     f0103d1b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103cec:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103cf2:	75 05                	jne    f0103cf9 <strtol+0x36>
f0103cf4:	80 39 30             	cmpb   $0x30,(%ecx)
f0103cf7:	74 2c                	je     f0103d25 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103cf9:	85 db                	test   %ebx,%ebx
f0103cfb:	75 0a                	jne    f0103d07 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103cfd:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0103d02:	80 39 30             	cmpb   $0x30,(%ecx)
f0103d05:	74 28                	je     f0103d2f <strtol+0x6c>
		base = 10;
f0103d07:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d0c:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103d0f:	eb 50                	jmp    f0103d61 <strtol+0x9e>
		s++;
f0103d11:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0103d14:	bf 00 00 00 00       	mov    $0x0,%edi
f0103d19:	eb d1                	jmp    f0103cec <strtol+0x29>
		s++, neg = 1;
f0103d1b:	83 c1 01             	add    $0x1,%ecx
f0103d1e:	bf 01 00 00 00       	mov    $0x1,%edi
f0103d23:	eb c7                	jmp    f0103cec <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103d25:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103d29:	74 0e                	je     f0103d39 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0103d2b:	85 db                	test   %ebx,%ebx
f0103d2d:	75 d8                	jne    f0103d07 <strtol+0x44>
		s++, base = 8;
f0103d2f:	83 c1 01             	add    $0x1,%ecx
f0103d32:	bb 08 00 00 00       	mov    $0x8,%ebx
f0103d37:	eb ce                	jmp    f0103d07 <strtol+0x44>
		s += 2, base = 16;
f0103d39:	83 c1 02             	add    $0x2,%ecx
f0103d3c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103d41:	eb c4                	jmp    f0103d07 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0103d43:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103d46:	89 f3                	mov    %esi,%ebx
f0103d48:	80 fb 19             	cmp    $0x19,%bl
f0103d4b:	77 29                	ja     f0103d76 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0103d4d:	0f be d2             	movsbl %dl,%edx
f0103d50:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103d53:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103d56:	7d 30                	jge    f0103d88 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0103d58:	83 c1 01             	add    $0x1,%ecx
f0103d5b:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103d5f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0103d61:	0f b6 11             	movzbl (%ecx),%edx
f0103d64:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103d67:	89 f3                	mov    %esi,%ebx
f0103d69:	80 fb 09             	cmp    $0x9,%bl
f0103d6c:	77 d5                	ja     f0103d43 <strtol+0x80>
			dig = *s - '0';
f0103d6e:	0f be d2             	movsbl %dl,%edx
f0103d71:	83 ea 30             	sub    $0x30,%edx
f0103d74:	eb dd                	jmp    f0103d53 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0103d76:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103d79:	89 f3                	mov    %esi,%ebx
f0103d7b:	80 fb 19             	cmp    $0x19,%bl
f0103d7e:	77 08                	ja     f0103d88 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0103d80:	0f be d2             	movsbl %dl,%edx
f0103d83:	83 ea 37             	sub    $0x37,%edx
f0103d86:	eb cb                	jmp    f0103d53 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103d88:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103d8c:	74 05                	je     f0103d93 <strtol+0xd0>
		*endptr = (char *) s;
f0103d8e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103d91:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0103d93:	89 c2                	mov    %eax,%edx
f0103d95:	f7 da                	neg    %edx
f0103d97:	85 ff                	test   %edi,%edi
f0103d99:	0f 45 c2             	cmovne %edx,%eax
}
f0103d9c:	5b                   	pop    %ebx
f0103d9d:	5e                   	pop    %esi
f0103d9e:	5f                   	pop    %edi
f0103d9f:	5d                   	pop    %ebp
f0103da0:	c3                   	ret    
f0103da1:	66 90                	xchg   %ax,%ax
f0103da3:	66 90                	xchg   %ax,%ax
f0103da5:	66 90                	xchg   %ax,%ax
f0103da7:	66 90                	xchg   %ax,%ax
f0103da9:	66 90                	xchg   %ax,%ax
f0103dab:	66 90                	xchg   %ax,%ax
f0103dad:	66 90                	xchg   %ax,%ax
f0103daf:	90                   	nop

f0103db0 <__udivdi3>:
f0103db0:	55                   	push   %ebp
f0103db1:	57                   	push   %edi
f0103db2:	56                   	push   %esi
f0103db3:	53                   	push   %ebx
f0103db4:	83 ec 1c             	sub    $0x1c,%esp
f0103db7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0103dbb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103dbf:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103dc3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0103dc7:	85 d2                	test   %edx,%edx
f0103dc9:	75 35                	jne    f0103e00 <__udivdi3+0x50>
f0103dcb:	39 f3                	cmp    %esi,%ebx
f0103dcd:	0f 87 bd 00 00 00    	ja     f0103e90 <__udivdi3+0xe0>
f0103dd3:	85 db                	test   %ebx,%ebx
f0103dd5:	89 d9                	mov    %ebx,%ecx
f0103dd7:	75 0b                	jne    f0103de4 <__udivdi3+0x34>
f0103dd9:	b8 01 00 00 00       	mov    $0x1,%eax
f0103dde:	31 d2                	xor    %edx,%edx
f0103de0:	f7 f3                	div    %ebx
f0103de2:	89 c1                	mov    %eax,%ecx
f0103de4:	31 d2                	xor    %edx,%edx
f0103de6:	89 f0                	mov    %esi,%eax
f0103de8:	f7 f1                	div    %ecx
f0103dea:	89 c6                	mov    %eax,%esi
f0103dec:	89 e8                	mov    %ebp,%eax
f0103dee:	89 f7                	mov    %esi,%edi
f0103df0:	f7 f1                	div    %ecx
f0103df2:	89 fa                	mov    %edi,%edx
f0103df4:	83 c4 1c             	add    $0x1c,%esp
f0103df7:	5b                   	pop    %ebx
f0103df8:	5e                   	pop    %esi
f0103df9:	5f                   	pop    %edi
f0103dfa:	5d                   	pop    %ebp
f0103dfb:	c3                   	ret    
f0103dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103e00:	39 f2                	cmp    %esi,%edx
f0103e02:	77 7c                	ja     f0103e80 <__udivdi3+0xd0>
f0103e04:	0f bd fa             	bsr    %edx,%edi
f0103e07:	83 f7 1f             	xor    $0x1f,%edi
f0103e0a:	0f 84 98 00 00 00    	je     f0103ea8 <__udivdi3+0xf8>
f0103e10:	89 f9                	mov    %edi,%ecx
f0103e12:	b8 20 00 00 00       	mov    $0x20,%eax
f0103e17:	29 f8                	sub    %edi,%eax
f0103e19:	d3 e2                	shl    %cl,%edx
f0103e1b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103e1f:	89 c1                	mov    %eax,%ecx
f0103e21:	89 da                	mov    %ebx,%edx
f0103e23:	d3 ea                	shr    %cl,%edx
f0103e25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103e29:	09 d1                	or     %edx,%ecx
f0103e2b:	89 f2                	mov    %esi,%edx
f0103e2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103e31:	89 f9                	mov    %edi,%ecx
f0103e33:	d3 e3                	shl    %cl,%ebx
f0103e35:	89 c1                	mov    %eax,%ecx
f0103e37:	d3 ea                	shr    %cl,%edx
f0103e39:	89 f9                	mov    %edi,%ecx
f0103e3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103e3f:	d3 e6                	shl    %cl,%esi
f0103e41:	89 eb                	mov    %ebp,%ebx
f0103e43:	89 c1                	mov    %eax,%ecx
f0103e45:	d3 eb                	shr    %cl,%ebx
f0103e47:	09 de                	or     %ebx,%esi
f0103e49:	89 f0                	mov    %esi,%eax
f0103e4b:	f7 74 24 08          	divl   0x8(%esp)
f0103e4f:	89 d6                	mov    %edx,%esi
f0103e51:	89 c3                	mov    %eax,%ebx
f0103e53:	f7 64 24 0c          	mull   0xc(%esp)
f0103e57:	39 d6                	cmp    %edx,%esi
f0103e59:	72 0c                	jb     f0103e67 <__udivdi3+0xb7>
f0103e5b:	89 f9                	mov    %edi,%ecx
f0103e5d:	d3 e5                	shl    %cl,%ebp
f0103e5f:	39 c5                	cmp    %eax,%ebp
f0103e61:	73 5d                	jae    f0103ec0 <__udivdi3+0x110>
f0103e63:	39 d6                	cmp    %edx,%esi
f0103e65:	75 59                	jne    f0103ec0 <__udivdi3+0x110>
f0103e67:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0103e6a:	31 ff                	xor    %edi,%edi
f0103e6c:	89 fa                	mov    %edi,%edx
f0103e6e:	83 c4 1c             	add    $0x1c,%esp
f0103e71:	5b                   	pop    %ebx
f0103e72:	5e                   	pop    %esi
f0103e73:	5f                   	pop    %edi
f0103e74:	5d                   	pop    %ebp
f0103e75:	c3                   	ret    
f0103e76:	8d 76 00             	lea    0x0(%esi),%esi
f0103e79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0103e80:	31 ff                	xor    %edi,%edi
f0103e82:	31 c0                	xor    %eax,%eax
f0103e84:	89 fa                	mov    %edi,%edx
f0103e86:	83 c4 1c             	add    $0x1c,%esp
f0103e89:	5b                   	pop    %ebx
f0103e8a:	5e                   	pop    %esi
f0103e8b:	5f                   	pop    %edi
f0103e8c:	5d                   	pop    %ebp
f0103e8d:	c3                   	ret    
f0103e8e:	66 90                	xchg   %ax,%ax
f0103e90:	31 ff                	xor    %edi,%edi
f0103e92:	89 e8                	mov    %ebp,%eax
f0103e94:	89 f2                	mov    %esi,%edx
f0103e96:	f7 f3                	div    %ebx
f0103e98:	89 fa                	mov    %edi,%edx
f0103e9a:	83 c4 1c             	add    $0x1c,%esp
f0103e9d:	5b                   	pop    %ebx
f0103e9e:	5e                   	pop    %esi
f0103e9f:	5f                   	pop    %edi
f0103ea0:	5d                   	pop    %ebp
f0103ea1:	c3                   	ret    
f0103ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103ea8:	39 f2                	cmp    %esi,%edx
f0103eaa:	72 06                	jb     f0103eb2 <__udivdi3+0x102>
f0103eac:	31 c0                	xor    %eax,%eax
f0103eae:	39 eb                	cmp    %ebp,%ebx
f0103eb0:	77 d2                	ja     f0103e84 <__udivdi3+0xd4>
f0103eb2:	b8 01 00 00 00       	mov    $0x1,%eax
f0103eb7:	eb cb                	jmp    f0103e84 <__udivdi3+0xd4>
f0103eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103ec0:	89 d8                	mov    %ebx,%eax
f0103ec2:	31 ff                	xor    %edi,%edi
f0103ec4:	eb be                	jmp    f0103e84 <__udivdi3+0xd4>
f0103ec6:	66 90                	xchg   %ax,%ax
f0103ec8:	66 90                	xchg   %ax,%ax
f0103eca:	66 90                	xchg   %ax,%ax
f0103ecc:	66 90                	xchg   %ax,%ax
f0103ece:	66 90                	xchg   %ax,%ax

f0103ed0 <__umoddi3>:
f0103ed0:	55                   	push   %ebp
f0103ed1:	57                   	push   %edi
f0103ed2:	56                   	push   %esi
f0103ed3:	53                   	push   %ebx
f0103ed4:	83 ec 1c             	sub    $0x1c,%esp
f0103ed7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0103edb:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103edf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103ee3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103ee7:	85 ed                	test   %ebp,%ebp
f0103ee9:	89 f0                	mov    %esi,%eax
f0103eeb:	89 da                	mov    %ebx,%edx
f0103eed:	75 19                	jne    f0103f08 <__umoddi3+0x38>
f0103eef:	39 df                	cmp    %ebx,%edi
f0103ef1:	0f 86 b1 00 00 00    	jbe    f0103fa8 <__umoddi3+0xd8>
f0103ef7:	f7 f7                	div    %edi
f0103ef9:	89 d0                	mov    %edx,%eax
f0103efb:	31 d2                	xor    %edx,%edx
f0103efd:	83 c4 1c             	add    $0x1c,%esp
f0103f00:	5b                   	pop    %ebx
f0103f01:	5e                   	pop    %esi
f0103f02:	5f                   	pop    %edi
f0103f03:	5d                   	pop    %ebp
f0103f04:	c3                   	ret    
f0103f05:	8d 76 00             	lea    0x0(%esi),%esi
f0103f08:	39 dd                	cmp    %ebx,%ebp
f0103f0a:	77 f1                	ja     f0103efd <__umoddi3+0x2d>
f0103f0c:	0f bd cd             	bsr    %ebp,%ecx
f0103f0f:	83 f1 1f             	xor    $0x1f,%ecx
f0103f12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103f16:	0f 84 b4 00 00 00    	je     f0103fd0 <__umoddi3+0x100>
f0103f1c:	b8 20 00 00 00       	mov    $0x20,%eax
f0103f21:	89 c2                	mov    %eax,%edx
f0103f23:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103f27:	29 c2                	sub    %eax,%edx
f0103f29:	89 c1                	mov    %eax,%ecx
f0103f2b:	89 f8                	mov    %edi,%eax
f0103f2d:	d3 e5                	shl    %cl,%ebp
f0103f2f:	89 d1                	mov    %edx,%ecx
f0103f31:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103f35:	d3 e8                	shr    %cl,%eax
f0103f37:	09 c5                	or     %eax,%ebp
f0103f39:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103f3d:	89 c1                	mov    %eax,%ecx
f0103f3f:	d3 e7                	shl    %cl,%edi
f0103f41:	89 d1                	mov    %edx,%ecx
f0103f43:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103f47:	89 df                	mov    %ebx,%edi
f0103f49:	d3 ef                	shr    %cl,%edi
f0103f4b:	89 c1                	mov    %eax,%ecx
f0103f4d:	89 f0                	mov    %esi,%eax
f0103f4f:	d3 e3                	shl    %cl,%ebx
f0103f51:	89 d1                	mov    %edx,%ecx
f0103f53:	89 fa                	mov    %edi,%edx
f0103f55:	d3 e8                	shr    %cl,%eax
f0103f57:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103f5c:	09 d8                	or     %ebx,%eax
f0103f5e:	f7 f5                	div    %ebp
f0103f60:	d3 e6                	shl    %cl,%esi
f0103f62:	89 d1                	mov    %edx,%ecx
f0103f64:	f7 64 24 08          	mull   0x8(%esp)
f0103f68:	39 d1                	cmp    %edx,%ecx
f0103f6a:	89 c3                	mov    %eax,%ebx
f0103f6c:	89 d7                	mov    %edx,%edi
f0103f6e:	72 06                	jb     f0103f76 <__umoddi3+0xa6>
f0103f70:	75 0e                	jne    f0103f80 <__umoddi3+0xb0>
f0103f72:	39 c6                	cmp    %eax,%esi
f0103f74:	73 0a                	jae    f0103f80 <__umoddi3+0xb0>
f0103f76:	2b 44 24 08          	sub    0x8(%esp),%eax
f0103f7a:	19 ea                	sbb    %ebp,%edx
f0103f7c:	89 d7                	mov    %edx,%edi
f0103f7e:	89 c3                	mov    %eax,%ebx
f0103f80:	89 ca                	mov    %ecx,%edx
f0103f82:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0103f87:	29 de                	sub    %ebx,%esi
f0103f89:	19 fa                	sbb    %edi,%edx
f0103f8b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0103f8f:	89 d0                	mov    %edx,%eax
f0103f91:	d3 e0                	shl    %cl,%eax
f0103f93:	89 d9                	mov    %ebx,%ecx
f0103f95:	d3 ee                	shr    %cl,%esi
f0103f97:	d3 ea                	shr    %cl,%edx
f0103f99:	09 f0                	or     %esi,%eax
f0103f9b:	83 c4 1c             	add    $0x1c,%esp
f0103f9e:	5b                   	pop    %ebx
f0103f9f:	5e                   	pop    %esi
f0103fa0:	5f                   	pop    %edi
f0103fa1:	5d                   	pop    %ebp
f0103fa2:	c3                   	ret    
f0103fa3:	90                   	nop
f0103fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103fa8:	85 ff                	test   %edi,%edi
f0103faa:	89 f9                	mov    %edi,%ecx
f0103fac:	75 0b                	jne    f0103fb9 <__umoddi3+0xe9>
f0103fae:	b8 01 00 00 00       	mov    $0x1,%eax
f0103fb3:	31 d2                	xor    %edx,%edx
f0103fb5:	f7 f7                	div    %edi
f0103fb7:	89 c1                	mov    %eax,%ecx
f0103fb9:	89 d8                	mov    %ebx,%eax
f0103fbb:	31 d2                	xor    %edx,%edx
f0103fbd:	f7 f1                	div    %ecx
f0103fbf:	89 f0                	mov    %esi,%eax
f0103fc1:	f7 f1                	div    %ecx
f0103fc3:	e9 31 ff ff ff       	jmp    f0103ef9 <__umoddi3+0x29>
f0103fc8:	90                   	nop
f0103fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103fd0:	39 dd                	cmp    %ebx,%ebp
f0103fd2:	72 08                	jb     f0103fdc <__umoddi3+0x10c>
f0103fd4:	39 f7                	cmp    %esi,%edi
f0103fd6:	0f 87 21 ff ff ff    	ja     f0103efd <__umoddi3+0x2d>
f0103fdc:	89 da                	mov    %ebx,%edx
f0103fde:	89 f0                	mov    %esi,%eax
f0103fe0:	29 f8                	sub    %edi,%eax
f0103fe2:	19 ea                	sbb    %ebp,%edx
f0103fe4:	e9 14 ff ff ff       	jmp    f0103efd <__umoddi3+0x2d>
