0000000000007540 <bpf_csum_diff_optimized>:
    7540:	f3 0f 1e fa          	endbr64
    7544:	41 54                	push   %r12
    7546:	be 14 00 00 00       	mov    $0x14,%esi
    754b:	49 89 d4             	mov    %rdx,%r12
    754e:	31 d2                	xor    %edx,%edx
    7550:	55                   	push   %rbp
    7551:	4c 89 c5             	mov    %r8,%rbp
    7554:	53                   	push   %rbx
    7555:	e8 00 00 00 00       	call   755a <bpf_csum_diff_optimized+0x1a>
    755a:	89 ea                	mov    %ebp,%edx
    755c:	4c 89 e7             	mov    %r12,%rdi
    755f:	be 14 00 00 00       	mov    $0x14,%esi
    7564:	89 c3                	mov    %eax,%ebx
    7566:	e8 00 00 00 00       	call   756b <bpf_csum_diff_optimized+0x2b>
    756b:	f7 d3                	not    %ebx
    756d:	89 c2                	mov    %eax,%edx
    756f:	01 da                	add    %ebx,%edx
    7571:	83 d2 00             	adc    $0x0,%edx
    7574:	89 d0                	mov    %edx,%eax
    7576:	5b                   	pop    %rbx
    7577:	5d                   	pop    %rbp
    7578:	c1 c0 10             	rol    $0x10,%eax
    757b:	41 5c                	pop    %r12
    757d:	01 d0                	add    %edx,%eax
    757f:	c1 e8 10             	shr    $0x10,%eax
    7582:	e9 00 00 00 00       	jmp    7587 <bpf_csum_diff_optimized+0x47>
    7587:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    758e:	00 00 
    7590:	90                   	nop
    7591:	90                   	nop
    7592:	90                   	nop
    7593:	90                   	nop
    7594:	90                   	nop
    7595:	90                   	nop
    7596:	90                   	nop
    7597:	90                   	nop
    7598:	90                   	nop
    7599:	90                   	nop
    759a:	90                   	nop
    759b:	90                   	nop
    759c:	90                   	nop
    759d:	90                   	nop
    759e:	90                   	nop
    759f:	90                   	nop
