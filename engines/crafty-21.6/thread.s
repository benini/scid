	.file	"thread.c"
	.text
.globl Thread
	.type	Thread, @function
Thread:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$20, %esp
	movl	$0, -8(%ebp)
	movl	shared, %eax
	addl	$70248, %eax
	subl	$12, %esp
	pushl	%eax
	call	LockX86
	addl	$16, %esp
	movl	$0, -12(%ebp)
	jmp	.L2
.L3:
	leal	-12(%ebp), %eax
	incl	(%eax)
.L2:
	movl	shared, %eax
	movl	70340(%eax), %eax
	cmpl	-12(%ebp), %eax
	jle	.L4
	movl	shared, %eax
	movl	-12(%ebp), %edx
	movl	70240(%eax,%edx,4), %eax
	testl	%eax, %eax
	jne	.L3
.L4:
	movl	shared, %eax
	movl	70340(%eax), %eax
	cmpl	-12(%ebp), %eax
	je	.L6
	movl	8(%ebp), %eax
	movb	44644(%eax), %al
	testb	%al, %al
	je	.L8
.L6:
	movl	shared, %eax
	addl	$70248, %eax
	subl	$12, %esp
	pushl	%eax
	call	UnlockX86
	addl	$16, %esp
	movl	$0, -24(%ebp)
	jmp	.L9
.L8:
	movl	shared, %eax
	movl	$1, 70272(%eax)
	movl	shared, %edx
	movl	70260(%edx), %eax
	incl	%eax
	movl	%eax, 70260(%edx)
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	44640(%eax), %eax
	movl	$0, 70240(%edx,%eax,4)
	movl	8(%ebp), %eax
	movl	$0, 44692(%eax)
	movl	$0, -12(%ebp)
	jmp	.L10
.L11:
	movl	-12(%ebp), %edx
	movl	8(%ebp), %eax
	movl	$0, 44680(%eax,%edx,4)
	movl	shared, %edx
	movl	-12(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	testl	%eax, %eax
	jne	.L12
	subl	$8, %esp
	pushl	-12(%ebp)
	pushl	8(%ebp)
	call	CopyToSMP
	addl	$16, %esp
	movl	%eax, -16(%ebp)
	cmpl	$0, -16(%ebp)
	je	.L14
	leal	-8(%ebp), %eax
	incl	(%eax)
	movl	-12(%ebp), %ecx
	movl	8(%ebp), %edx
	movl	-16(%ebp), %eax
	movl	%eax, 44680(%edx,%ecx,4)
	movl	-16(%ebp), %edx
	movl	-12(%ebp), %eax
	movl	%eax, 44640(%edx)
	movl	-16(%ebp), %edx
	movl	8(%ebp), %eax
	movl	%eax, 44688(%edx)
	movl	8(%ebp), %eax
	movl	44692(%eax), %eax
	leal	1(%eax), %edx
	movl	8(%ebp), %eax
	movl	%edx, 44692(%eax)
	jmp	.L14
.L12:
	movl	-12(%ebp), %edx
	movl	8(%ebp), %eax
	movl	$0, 44680(%eax,%edx,4)
.L14:
	leal	-12(%ebp), %eax
	incl	(%eax)
.L10:
	movl	shared, %eax
	movl	70340(%eax), %eax
	cmpl	-12(%ebp), %eax
	jle	.L16
	movl	shared, %eax
	movl	70348(%eax), %eax
	cmpl	-8(%ebp), %eax
	jg	.L11
.L16:
	movl	8(%ebp), %eax
	movl	44704(%eax), %edx
	movl	8(%ebp), %eax
	movl	%edx, 44608(%eax)
	cmpl	$0, -8(%ebp)
	jne	.L18
	movl	shared, %eax
	addl	$70248, %eax
	subl	$12, %esp
	pushl	%eax
	call	UnlockX86
	addl	$16, %esp
	movl	shared, %ecx
	movl	8(%ebp), %eax
	movl	44640(%eax), %edx
	movl	8(%ebp), %eax
	movl	%eax, 70240(%ecx,%edx,4)
	movl	shared, %eax
	movl	$0, 70272(%eax)
	movl	$0, -24(%ebp)
	jmp	.L9
.L18:
	movl	$0, -12(%ebp)
	jmp	.L20
.L21:
	movl	-12(%ebp), %eax
	movl	8(%ebp), %edx
	movl	44680(%edx,%eax,4), %eax
	testl	%eax, %eax
	je	.L22
	movl	shared, %ecx
	movl	-12(%ebp), %ebx
	movl	-12(%ebp), %edx
	movl	8(%ebp), %eax
	movl	44680(%eax,%edx,4), %eax
	movl	%eax, 70240(%ecx,%ebx,4)
.L22:
	leal	-12(%ebp), %eax
	incl	(%eax)
.L20:
	movl	shared, %eax
	movl	70340(%eax), %eax
	cmpl	-12(%ebp), %eax
	jg	.L21
	movl	shared, %eax
	movl	$0, 70272(%eax)
	movl	shared, %eax
	addl	$70248, %eax
	subl	$12, %esp
	pushl	%eax
	call	UnlockX86
	addl	$16, %esp
	movl	8(%ebp), %eax
	movl	44640(%eax), %eax
	subl	$8, %esp
	pushl	8(%ebp)
	pushl	%eax
	call	ThreadWait
	addl	$16, %esp
	movl	$1, -24(%ebp)
.L9:
	movl	-24(%ebp), %eax
	movl	-4(%ebp), %ebx
	leave
	ret
	.size	Thread, .-Thread
	.type	UnlockX86, @function
UnlockX86:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$16, %esp
	movl	8(%ebp), %eax
#APP
	movl    $0, (%eax)
#NO_APP
	movl	%edx, %eax
	movl	%eax, -4(%ebp)
	leave
	ret
	.size	UnlockX86, .-UnlockX86
	.type	LockX86, @function
LockX86:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$16, %esp
	movl	8(%ebp), %eax
#APP
	1:          movl    $1, %edx
	            xchgl   (%eax), %edx
	            testl   %edx, %edx
	            jz      3f
	2:          pause
	            movl    (%eax), %edx
	            testl   %edx, %edx
	            jnz     2b
	            jmp     1b
	3:
	
#NO_APP
	movl	%edx, %eax
	movl	%eax, -4(%ebp)
	leave
	ret
	.size	LockX86, .-LockX86
.globl WaitForAllThreadsInitialized
	.type	WaitForAllThreadsInitialized, @function
WaitForAllThreadsInitialized:
	pushl	%ebp
	movl	%esp, %ebp
.L31:
	movl	shared, %eax
	movl	70284(%eax), %edx
	movl	shared, %eax
	movl	70340(%eax), %eax
	cmpl	%eax, %edx
	jl	.L31
	leave
	ret
	.size	WaitForAllThreadsInitialized, .-WaitForAllThreadsInitialized
.globl ThreadInit
	.type	ThreadInit, @function
ThreadInit:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %eax
	movl	%eax, -4(%ebp)
	movl	$0, -8(%ebp)
	jmp	.L35
.L36:
	movl	shared, %edx
	movl	-4(%ebp), %eax
	sall	$6, %eax
	addl	-8(%ebp), %eax
	incl	%eax
	movl	69724(%edx,%eax,4), %eax
	movl	%eax, %edx
	movl	$44728, %eax
	subl	$4, %esp
	pushl	%eax
	pushl	$0
	pushl	%edx
	call	memset
	addl	$16, %esp
	movl	shared, %edx
	movl	-4(%ebp), %eax
	sall	$6, %eax
	addl	-8(%ebp), %eax
	incl	%eax
	movl	69724(%edx,%eax,4), %eax
	movl	$0, 44724(%eax)
	movl	shared, %edx
	movl	-4(%ebp), %eax
	sall	$6, %eax
	addl	-8(%ebp), %eax
	incl	%eax
	movl	69724(%edx,%eax,4), %eax
	movl	$-1, 44688(%eax)
	movl	shared, %edx
	movl	-4(%ebp), %eax
	sall	$6, %eax
	addl	-8(%ebp), %eax
	incl	%eax
	movl	69724(%edx,%eax,4), %eax
	movl	$0, 44636(%eax)
	leal	-8(%ebp), %eax
	incl	(%eax)
.L35:
	cmpl	$63, -8(%ebp)
	jle	.L36
	movl	shared, %eax
	addl	$70248, %eax
	pushl	%eax
	call	LockX86
	addl	$4, %esp
	movl	shared, %edx
	movl	70284(%edx), %eax
	incl	%eax
	movl	%eax, 70284(%edx)
	movl	shared, %eax
	addl	$70248, %eax
	pushl	%eax
	call	UnlockX86
	addl	$4, %esp
	call	WaitForAllThreadsInitialized
	movl	8(%ebp), %eax
	subl	$8, %esp
	pushl	$0
	pushl	%eax
	call	ThreadWait
	addl	$16, %esp
	movl	$0, %eax
	leave
	ret
	.size	ThreadInit, .-ThreadInit
.globl ThreadStop
	.type	ThreadStop, @function
ThreadStop:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$16, %esp
	movl	8(%ebp), %eax
	addl	$44636, %eax
	pushl	%eax
	call	LockX86
	addl	$4, %esp
	movl	8(%ebp), %eax
	movb	$1, 44644(%eax)
	movl	$0, -4(%ebp)
	jmp	.L40
.L41:
	movl	-4(%ebp), %eax
	movl	8(%ebp), %edx
	movl	44680(%edx,%eax,4), %eax
	testl	%eax, %eax
	je	.L42
	movl	-4(%ebp), %eax
	movl	8(%ebp), %edx
	movl	44680(%edx,%eax,4), %eax
	subl	$12, %esp
	pushl	%eax
	call	ThreadStop
	addl	$16, %esp
.L42:
	leal	-4(%ebp), %eax
	incl	(%eax)
.L40:
	movl	shared, %eax
	movl	70340(%eax), %eax
	cmpl	-4(%ebp), %eax
	jg	.L41
	movl	8(%ebp), %eax
	addl	$44636, %eax
	pushl	%eax
	call	UnlockX86
	addl	$4, %esp
	leave
	ret
	.size	ThreadStop, .-ThreadStop
	.section	.rodata
.LC0:
	.string	"thread %d exiting\n"
	.text
.globl ThreadWait
	.type	ThreadWait, @function
ThreadWait:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx
	subl	$44, %esp
.L47:
	movl	shared, %eax
	addl	$70248, %eax
	pushl	%eax
	call	LockX86
	addl	$4, %esp
	movl	shared, %edx
	movl	70276(%edx), %eax
	incl	%eax
	movl	%eax, 70276(%edx)
	movl	shared, %eax
	addl	$70248, %eax
	pushl	%eax
	call	UnlockX86
	addl	$4, %esp
	jmp	.L64
.L48:
.L64:
	movl	shared, %eax
	movl	8(%ebp), %edx
	movl	70240(%eax,%edx,4), %eax
	testl	%eax, %eax
	jne	.L49
	movl	shared, %eax
	movl	69688(%eax), %eax
	testl	%eax, %eax
	jne	.L49
	cmpl	$0, 12(%ebp)
	je	.L48
	movl	12(%ebp), %eax
	movl	44692(%eax), %eax
	testl	%eax, %eax
	jne	.L48
.L49:
	movl	shared, %eax
	movl	69688(%eax), %eax
	testl	%eax, %eax
	je	.L53
	movl	$0, -44(%ebp)
	jmp	.L55
.L53:
	movl	shared, %eax
	addl	$70248, %eax
	pushl	%eax
	call	LockX86
	addl	$4, %esp
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	testl	%eax, %eax
	jne	.L56
	movl	shared, %ecx
	movl	8(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, 70240(%ecx,%edx,4)
.L56:
	movl	shared, %edx
	movl	70276(%edx), %eax
	decl	%eax
	movl	%eax, 70276(%edx)
	movl	shared, %eax
	addl	$70248, %eax
	pushl	%eax
	call	UnlockX86
	addl	$4, %esp
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	cmpl	12(%ebp), %eax
	jne	.L58
	movl	$0, -44(%ebp)
	jmp	.L55
.L58:
	movl	shared, %eax
	movl	69688(%eax), %eax
	testl	%eax, %eax
	jne	.L60
	movl	shared, %eax
	movl	8(%ebp), %edx
	movl	70240(%eax,%edx,4), %eax
	cmpl	$-1, %eax
	jne	.L62
.L60:
	movl	shared, %eax
	addl	$70252, %eax
	pushl	%eax
	call	LockX86
	addl	$4, %esp
	subl	$4, %esp
	pushl	8(%ebp)
	pushl	$.LC0
	pushl	$128
	call	Print
	addl	$16, %esp
	movl	shared, %eax
	addl	$70252, %eax
	pushl	%eax
	call	UnlockX86
	addl	$4, %esp
	movl	$0, -44(%ebp)
	jmp	.L55
.L62:
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	movl	44720(%eax), %ebx
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	movl	44716(%eax), %esi
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	movl	44712(%eax), %edi
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	movl	44708(%eax), %eax
	movl	%eax, -40(%ebp)
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	movl	44704(%eax), %eax
	movl	%eax, -36(%ebp)
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	movl	44700(%eax), %eax
	movl	%eax, -32(%ebp)
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	movl	44696(%eax), %ecx
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	pushl	%ebx
	pushl	%esi
	pushl	%edi
	pushl	-40(%ebp)
	pushl	-36(%ebp)
	pushl	-32(%ebp)
	pushl	%ecx
	pushl	%eax
	call	SearchSMP
	addl	$32, %esp
	movl	%eax, -16(%ebp)
	movl	shared, %eax
	addl	$70248, %eax
	pushl	%eax
	call	LockX86
	addl	$4, %esp
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	movl	44688(%eax), %eax
	addl	$44636, %eax
	pushl	%eax
	call	LockX86
	addl	$4, %esp
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %ecx
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	movl	44688(%eax), %eax
	subl	$4, %esp
	pushl	-16(%ebp)
	pushl	%ecx
	pushl	%eax
	call	CopyFromSMP
	addl	$16, %esp
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	movl	44688(%eax), %edx
	movl	44692(%edx), %eax
	decl	%eax
	movl	%eax, 44692(%edx)
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	movl	44688(%eax), %edx
	movl	8(%ebp), %eax
	movl	$0, 44680(%edx,%eax,4)
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	70240(%edx,%eax,4), %eax
	movl	44688(%eax), %eax
	addl	$44636, %eax
	pushl	%eax
	call	UnlockX86
	addl	$4, %esp
	movl	shared, %edx
	movl	8(%ebp), %eax
	movl	$0, 70240(%edx,%eax,4)
	movl	shared, %eax
	addl	$70248, %eax
	pushl	%eax
	call	UnlockX86
	addl	$4, %esp
	jmp	.L47
.L55:
	movl	-44(%ebp), %eax
	leal	-12(%ebp), %esp
	popl	%ebx
	popl	%esi
	popl	%edi
	leave
	ret
	.size	ThreadWait, .-ThreadWait
	.ident	"GCC: (GNU) 4.0.0 20050519 (Red Hat 4.0.0-8)"
	.section	.note.GNU-stack,"",@progbits
