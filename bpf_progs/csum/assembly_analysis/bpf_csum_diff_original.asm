00000000000074b0 <bpf_csum_diff>:
    74b0:	f3 0f 1e fa          	endbr64
    74b4:	41 55                	push   %r13
    74b6:	41 54                	push   %r12
    74b8:	55                   	push   %rbp
    74b9:	48 89 d5             	mov    %rdx,%rbp
    74bc:	53                   	push   %rbx
    74bd:	44 89 c3             	mov    %r8d,%ebx
    74c0:	85 f6                	test   %esi,%esi
    74c2:	74 44                	je     7508 <bpf_csum_diff+0x58>
    74c4:	85 c9                	test   %ecx,%ecx
    74c6:	75 19                	jne    74e1 <bpf_csum_diff+0x31>
    74c8:	85 f6                	test   %esi,%esi
    74ca:	75 51                	jne    751d <bpf_csum_diff+0x6d>
    74cc:	89 d8                	mov    %ebx,%eax
    74ce:	c1 c0 10             	rol    $0x10,%eax
    74d1:	01 d8                	add    %ebx,%eax
    74d3:	5b                   	pop    %rbx
    74d4:	5d                   	pop    %rbp
    74d5:	c1 e8 10             	shr    $0x10,%eax
    74d8:	41 5c                	pop    %r12
    74da:	41 5d                	pop    %r13
    74dc:	e9 00 00 00 00       	jmp    74e1 <bpf_csum_diff+0x31>
    74e1:	41 89 cd             	mov    %ecx,%r13d
    74e4:	31 d2                	xor    %edx,%edx
    74e6:	e8 00 00 00 00       	call   74eb <bpf_csum_diff+0x3b>
    74eb:	89 da                	mov    %ebx,%edx
    74ed:	44 89 ee             	mov    %r13d,%esi
    74f0:	48 89 ef             	mov    %rbp,%rdi
    74f3:	41 89 c4             	mov    %eax,%r12d
    74f6:	e8 00 00 00 00       	call   74fb <bpf_csum_diff+0x4b>
    74fb:	41 f7 d4             	not    %r12d
    74fe:	89 c3                	mov    %eax,%ebx
    7500:	44 01 e3             	add    %r12d,%ebx
    7503:	83 d3 00             	adc    $0x0,%ebx
    7506:	eb c4                	jmp    74cc <bpf_csum_diff+0x1c>
    7508:	85 c9                	test   %ecx,%ecx
    750a:	74 bc                	je     74c8 <bpf_csum_diff+0x18>
    750c:	44 89 c2             	mov    %r8d,%edx
    750f:	89 ce                	mov    %ecx,%esi
    7511:	48 89 ef             	mov    %rbp,%rdi
    7514:	e8 00 00 00 00       	call   7519 <bpf_csum_diff+0x69>
    7519:	89 c3                	mov    %eax,%ebx
    751b:	eb af                	jmp    74cc <bpf_csum_diff+0x1c>
    751d:	44 89 c2             	mov    %r8d,%edx
    7520:	f7 d2                	not    %edx
    7522:	e8 00 00 00 00       	call   7527 <bpf_csum_diff+0x77>
    7527:	f7 d0                	not    %eax
    7529:	89 c3                	mov    %eax,%ebx
    752b:	eb 9f                	jmp    74cc <bpf_csum_diff+0x1c>
    752d:	0f 1f 00             	nopl   (%rax)
    7530:	90                   	nop
    7531:	90                   	nop
    7532:	90                   	nop
    7533:	90                   	nop
    7534:	90                   	nop
    7535:	90                   	nop
    7536:	90                   	nop
    7537:	90                   	nop
    7538:	90                   	nop
    7539:	90                   	nop
    753a:	90                   	nop
    753b:	90                   	nop
    753c:	90                   	nop
    753d:	90                   	nop
    753e:	90                   	nop
    753f:	90                   	nop
