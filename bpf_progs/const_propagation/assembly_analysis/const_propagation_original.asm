0000000000000010 <const_propagation_original>:
  10:	f3 0f 1e fa          	endbr64
  14:	48 81 ff e8 03 00 00 	cmp    $0x3e8,%rdi
  1b:	77 3b                	ja     58 <const_propagation_original+0x48>
  1d:	48 8d 46 ff          	lea    -0x1(%rsi),%rax
  21:	48 83 f8 09          	cmp    $0x9,%rax
  25:	77 31                	ja     58 <const_propagation_original+0x48>
  27:	48 0f af fe          	imul   %rsi,%rdi
  2b:	48 83 c7 64          	add    $0x64,%rdi
  2f:	48 89 f8             	mov    %rdi,%rax
  32:	48 83 e7 fe          	and    $0xfffffffffffffffe,%rdi
  36:	48 d1 f8             	sar    $1,%rax
  39:	48 8d 54 38 ce       	lea    -0x32(%rax,%rdi,1),%rdx
  3e:	48 89 d1             	mov    %rdx,%rcx
  41:	48 8d 04 12          	lea    (%rdx,%rdx,1),%rax
  45:	48 d1 f9             	sar    $1,%rcx
  48:	48 81 fa f5 01 00 00 	cmp    $0x1f5,%rdx
  4f:	48 0f 4d c1          	cmovge %rcx,%rax
  53:	e9 00 00 00 00       	jmp    58 <const_propagation_original+0x48>
  58:	48 c7 c0 ea ff ff ff 	mov    $0xffffffffffffffea,%rax
  5f:	e9 00 00 00 00       	jmp    64 <const_propagation_original+0x54>
  64:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  6b:	00 00 00 00 
  6f:	90                   	nop
  70:	90                   	nop
  71:	90                   	nop
  72:	90                   	nop
  73:	90                   	nop
  74:	90                   	nop
  75:	90                   	nop
  76:	90                   	nop
  77:	90                   	nop
  78:	90                   	nop
  79:	90                   	nop
  7a:	90                   	nop
  7b:	90                   	nop
  7c:	90                   	nop
  7d:	90                   	nop
  7e:	90                   	nop
  7f:	90                   	nop

