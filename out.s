	.globl	main
	.type	main, @function
main:
LBL0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset	16
	.cfi_offset	6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register	6
	subq	$8192, %rsp
	movq	$24, %rdi
	call	malloc
	movq	%rax, -8(%rbp)
	call	malloc
	movq	-8(%rbp), %r13
	movq	$1, (%r13)
	movq	-8(%rbp), %r13
	movq	$8, 8(%r13)
	movq	-8(%rbp), %r13
	movb	$99, 16(%r13)
	movq	-8(%rbp), %r13
	movb	$111, 17(%r13)
	movq	-8(%rbp), %r13
	movb	$109, 18(%r13)
	movq	-8(%rbp), %r13
	movb	$109, 19(%r13)
	movq	-8(%rbp), %r13
	movb	$101, 20(%r13)
	movq	-8(%rbp), %r13
	movb	$110, 21(%r13)
	movq	-8(%rbp), %r13
	movb	$116, 22(%r13)
	movq	-8(%rbp), %r13
	movb	$10, 23(%r13)
	movq	-8(%rbp), %r10
	movq	%r10, -16(%rbp)
	movq	$1, %r11
	movq	-16(%rbp), %r13
	movq	(%r13), %r10
	addq	%r10, %r11
	movq	-16(%rbp), %r13
	movq	%r11, (%r13)
	movq	$0, -32(%rbp)
	movq	$22, %rdi
	call	malloc
	movq	%rax, -64(%rbp)
	call	malloc
	movq	-64(%rbp), %r13
	movq	$1, (%r13)
	movq	-64(%rbp), %r13
	movq	$6, 8(%r13)
	movq	-64(%rbp), %r13
	movb	$115, 16(%r13)
	movq	-64(%rbp), %r13
	movb	$97, 17(%r13)
	movq	-64(%rbp), %r13
	movb	$108, 18(%r13)
	movq	-64(%rbp), %r13
	movb	$117, 19(%r13)
	movq	-64(%rbp), %r13
	movb	$116, 20(%r13)
	movq	-64(%rbp), %r13
	movb	$10, 21(%r13)
	movq	-64(%rbp), %r10
	movq	%r10, -128(%rbp)
	movq	$1, %r11
	movq	-128(%rbp), %r13
	movq	(%r13), %r10
	addq	%r10, %r11
	movq	-128(%rbp), %r13
	movq	%r11, (%r13)
	movq	$0, -256(%rbp)
LBL4:

	movq	-256(%rbp), %r11
	movq	-128(%rbp), %r13
	movq	8(%r13), %r10
	cmpq	%r10, %r11
	setl	-505(%rbp)
	cmpb	$1, -505(%rbp)
	je	LBL3
	jmp	LBL2
LBL3:
	movq	-256(%rbp), %r11
	movq	-128(%rbp), %r10
	addq	%r10, %r11
	movq	%r11, -1024(%rbp)
	movq	-1024(%rbp), %r11
	movq	$16, %r10
	addq	%r10, %r11
	movq	%r11, -1024(%rbp)
	movq	-1024(%rbp), %r13
	movq	(%r13), %rdi
	call	putchar
	movq	$1, %r11
	movq	-256(%rbp), %r10
	addq	%r10, %r11
	movq	%r11, -256(%rbp)
	jmp	LBL4

LBL2:

LBL7:

	movq	-32(%rbp), %r11
	movq	-16(%rbp), %r13
	movq	8(%r13), %r10
	cmpq	%r10, %r11
	setl	-2041(%rbp)
	cmpb	$1, -2041(%rbp)
	je	LBL6
	jmp	LBL5
LBL6:
	movq	-32(%rbp), %r11
	movq	-16(%rbp), %r10
	addq	%r10, %r11
	movq	%r11, -4096(%rbp)
	movq	-4096(%rbp), %r11
	movq	$16, %r10
	addq	%r10, %r11
	movq	%r11, -4096(%rbp)
	movq	-4096(%rbp), %r13
	movq	(%r13), %rdi
	call	putchar
	movq	$1, %r11
	movq	-32(%rbp), %r10
	addq	%r10, %r11
	movq	%r11, -32(%rbp)
	jmp	LBL7

LBL5:

	movq	$1, %r11
	movq	-16(%rbp), %r13
	movq	(%r13), %r10
	subq	%r10, %r11
	movq	-16(%rbp), %r13
	movq	%r11, (%r13)
	movq	-16(%rbp), %r13
	cmpq	$1, (%r13)
	je	LBL8
	jmp	LBL9
LBL9:
	movq	-16(%rbp), %rdi
	call	free
	jmp	LBL10

LBL8:
	jmp	LBL10

LBL10:

	movq	$1, %r11
	movq	-8(%rbp), %r13
	movq	(%r13), %r10
	subq	%r10, %r11
	movq	-8(%rbp), %r13
	movq	%r11, (%r13)
	movq	-8(%rbp), %r13
	cmpq	$1, (%r13)
	je	LBL11
	jmp	LBL12
LBL12:
	movq	-8(%rbp), %rdi
	call	free
	jmp	LBL13

LBL11:
	jmp	LBL13

LBL13:

	movq	$1, %r11
	movq	-128(%rbp), %r13
	movq	(%r13), %r10
	subq	%r10, %r11
	movq	-128(%rbp), %r13
	movq	%r11, (%r13)
	movq	-128(%rbp), %r13
	cmpq	$1, (%r13)
	je	LBL14
	jmp	LBL15
LBL15:
	movq	-128(%rbp), %rdi
	call	free
	jmp	LBL16

LBL14:
	jmp	LBL16

LBL16:

	movq	$1, %r11
	movq	-64(%rbp), %r13
	movq	(%r13), %r10
	subq	%r10, %r11
	movq	-64(%rbp), %r13
	movq	%r11, (%r13)
	movq	-64(%rbp), %r13
	cmpq	$1, (%r13)
	je	LBL17
	jmp	LBL18
LBL18:
	movq	-64(%rbp), %rdi
	call	free
	jmp	LBL19

LBL17:
	jmp	LBL19

LBL19:

LBL1:

	leave
	.cfi_def_cfa	7, 6
	ret
	.cfi_endproc	
	.size	main, .-main



