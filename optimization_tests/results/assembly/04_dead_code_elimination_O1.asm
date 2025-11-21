
build/04_dead_code_elimination_O1:     file format elf64-x86-64


Disassembly of section .init:

0000000000001000 <_init>:
    1000:	f3 0f 1e fa          	endbr64
    1004:	48 83 ec 08          	sub    rsp,0x8
    1008:	48 8b 05 d9 2f 00 00 	mov    rax,QWORD PTR [rip+0x2fd9]        # 3fe8 <__gmon_start__@Base>
    100f:	48 85 c0             	test   rax,rax
    1012:	74 02                	je     1016 <_init+0x16>
    1014:	ff d0                	call   rax
    1016:	48 83 c4 08          	add    rsp,0x8
    101a:	c3                   	ret

Disassembly of section .plt:

0000000000001020 <.plt>:
    1020:	ff 35 82 2f 00 00    	push   QWORD PTR [rip+0x2f82]        # 3fa8 <_GLOBAL_OFFSET_TABLE_+0x8>
    1026:	ff 25 84 2f 00 00    	jmp    QWORD PTR [rip+0x2f84]        # 3fb0 <_GLOBAL_OFFSET_TABLE_+0x10>
    102c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    1030:	f3 0f 1e fa          	endbr64
    1034:	68 00 00 00 00       	push   0x0
    1039:	e9 e2 ff ff ff       	jmp    1020 <_init+0x20>
    103e:	66 90                	xchg   ax,ax
    1040:	f3 0f 1e fa          	endbr64
    1044:	68 01 00 00 00       	push   0x1
    1049:	e9 d2 ff ff ff       	jmp    1020 <_init+0x20>
    104e:	66 90                	xchg   ax,ax
    1050:	f3 0f 1e fa          	endbr64
    1054:	68 02 00 00 00       	push   0x2
    1059:	e9 c2 ff ff ff       	jmp    1020 <_init+0x20>
    105e:	66 90                	xchg   ax,ax
    1060:	f3 0f 1e fa          	endbr64
    1064:	68 03 00 00 00       	push   0x3
    1069:	e9 b2 ff ff ff       	jmp    1020 <_init+0x20>
    106e:	66 90                	xchg   ax,ax

Disassembly of section .plt.got:

0000000000001070 <__cxa_finalize@plt>:
    1070:	f3 0f 1e fa          	endbr64
    1074:	ff 25 7e 2f 00 00    	jmp    QWORD PTR [rip+0x2f7e]        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    107a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

Disassembly of section .plt.sec:

0000000000001080 <puts@plt>:
    1080:	f3 0f 1e fa          	endbr64
    1084:	ff 25 2e 2f 00 00    	jmp    QWORD PTR [rip+0x2f2e]        # 3fb8 <puts@GLIBC_2.2.5>
    108a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

0000000000001090 <clock_gettime@plt>:
    1090:	f3 0f 1e fa          	endbr64
    1094:	ff 25 26 2f 00 00    	jmp    QWORD PTR [rip+0x2f26]        # 3fc0 <clock_gettime@GLIBC_2.17>
    109a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

00000000000010a0 <__stack_chk_fail@plt>:
    10a0:	f3 0f 1e fa          	endbr64
    10a4:	ff 25 1e 2f 00 00    	jmp    QWORD PTR [rip+0x2f1e]        # 3fc8 <__stack_chk_fail@GLIBC_2.4>
    10aa:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

00000000000010b0 <__printf_chk@plt>:
    10b0:	f3 0f 1e fa          	endbr64
    10b4:	ff 25 16 2f 00 00    	jmp    QWORD PTR [rip+0x2f16]        # 3fd0 <__printf_chk@GLIBC_2.3.4>
    10ba:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

Disassembly of section .text:

00000000000010c0 <_start>:
    10c0:	f3 0f 1e fa          	endbr64
    10c4:	31 ed                	xor    ebp,ebp
    10c6:	49 89 d1             	mov    r9,rdx
    10c9:	5e                   	pop    rsi
    10ca:	48 89 e2             	mov    rdx,rsp
    10cd:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
    10d1:	50                   	push   rax
    10d2:	54                   	push   rsp
    10d3:	45 31 c0             	xor    r8d,r8d
    10d6:	31 c9                	xor    ecx,ecx
    10d8:	48 8d 3d f3 00 00 00 	lea    rdi,[rip+0xf3]        # 11d2 <main>
    10df:	ff 15 f3 2e 00 00    	call   QWORD PTR [rip+0x2ef3]        # 3fd8 <__libc_start_main@GLIBC_2.34>
    10e5:	f4                   	hlt
    10e6:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    10ed:	00 00 00 

00000000000010f0 <deregister_tm_clones>:
    10f0:	48 8d 3d 19 2f 00 00 	lea    rdi,[rip+0x2f19]        # 4010 <__TMC_END__>
    10f7:	48 8d 05 12 2f 00 00 	lea    rax,[rip+0x2f12]        # 4010 <__TMC_END__>
    10fe:	48 39 f8             	cmp    rax,rdi
    1101:	74 15                	je     1118 <deregister_tm_clones+0x28>
    1103:	48 8b 05 d6 2e 00 00 	mov    rax,QWORD PTR [rip+0x2ed6]        # 3fe0 <_ITM_deregisterTMCloneTable@Base>
    110a:	48 85 c0             	test   rax,rax
    110d:	74 09                	je     1118 <deregister_tm_clones+0x28>
    110f:	ff e0                	jmp    rax
    1111:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    1118:	c3                   	ret
    1119:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001120 <register_tm_clones>:
    1120:	48 8d 3d e9 2e 00 00 	lea    rdi,[rip+0x2ee9]        # 4010 <__TMC_END__>
    1127:	48 8d 35 e2 2e 00 00 	lea    rsi,[rip+0x2ee2]        # 4010 <__TMC_END__>
    112e:	48 29 fe             	sub    rsi,rdi
    1131:	48 89 f0             	mov    rax,rsi
    1134:	48 c1 ee 3f          	shr    rsi,0x3f
    1138:	48 c1 f8 03          	sar    rax,0x3
    113c:	48 01 c6             	add    rsi,rax
    113f:	48 d1 fe             	sar    rsi,1
    1142:	74 14                	je     1158 <register_tm_clones+0x38>
    1144:	48 8b 05 a5 2e 00 00 	mov    rax,QWORD PTR [rip+0x2ea5]        # 3ff0 <_ITM_registerTMCloneTable@Base>
    114b:	48 85 c0             	test   rax,rax
    114e:	74 08                	je     1158 <register_tm_clones+0x38>
    1150:	ff e0                	jmp    rax
    1152:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    1158:	c3                   	ret
    1159:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001160 <__do_global_dtors_aux>:
    1160:	f3 0f 1e fa          	endbr64
    1164:	80 3d a5 2e 00 00 00 	cmp    BYTE PTR [rip+0x2ea5],0x0        # 4010 <__TMC_END__>
    116b:	75 2b                	jne    1198 <__do_global_dtors_aux+0x38>
    116d:	55                   	push   rbp
    116e:	48 83 3d 82 2e 00 00 	cmp    QWORD PTR [rip+0x2e82],0x0        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    1175:	00 
    1176:	48 89 e5             	mov    rbp,rsp
    1179:	74 0c                	je     1187 <__do_global_dtors_aux+0x27>
    117b:	48 8b 3d 86 2e 00 00 	mov    rdi,QWORD PTR [rip+0x2e86]        # 4008 <__dso_handle>
    1182:	e8 e9 fe ff ff       	call   1070 <__cxa_finalize@plt>
    1187:	e8 64 ff ff ff       	call   10f0 <deregister_tm_clones>
    118c:	c6 05 7d 2e 00 00 01 	mov    BYTE PTR [rip+0x2e7d],0x1        # 4010 <__TMC_END__>
    1193:	5d                   	pop    rbp
    1194:	c3                   	ret
    1195:	0f 1f 00             	nop    DWORD PTR [rax]
    1198:	c3                   	ret
    1199:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000011a0 <frame_dummy>:
    11a0:	f3 0f 1e fa          	endbr64
    11a4:	e9 77 ff ff ff       	jmp    1120 <register_tm_clones>

00000000000011a9 <compute_with_dead_code>:
    11a9:	f3 0f 1e fa          	endbr64
    11ad:	8d 47 0a             	lea    eax,[rdi+0xa]
    11b0:	c3                   	ret

00000000000011b1 <compute_optimized>:
    11b1:	f3 0f 1e fa          	endbr64
    11b5:	8d 47 0a             	lea    eax,[rdi+0xa]
    11b8:	c3                   	ret

00000000000011b9 <benchmark_dead_code_elimination>:
    11b9:	f3 0f 1e fa          	endbr64
    11bd:	b8 00 e1 f5 05       	mov    eax,0x5f5e100
    11c2:	83 e8 01             	sub    eax,0x1
    11c5:	75 fb                	jne    11c2 <benchmark_dead_code_elimination+0x9>
    11c7:	48 b8 80 59 80 70 79 	movabs rax,0x11c37970805980
    11ce:	c3 11 00 
    11d1:	c3                   	ret

00000000000011d2 <main>:
    11d2:	f3 0f 1e fa          	endbr64
    11d6:	53                   	push   rbx
    11d7:	48 83 ec 50          	sub    rsp,0x50
    11db:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    11e2:	00 00 
    11e4:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
    11e9:	31 c0                	xor    eax,eax
    11eb:	e8 c9 ff ff ff       	call   11b9 <benchmark_dead_code_elimination>
    11f0:	48 89 c3             	mov    rbx,rax
    11f3:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    11f8:	48 8d 74 24 20       	lea    rsi,[rsp+0x20]
    11fd:	bf 01 00 00 00       	mov    edi,0x1
    1202:	e8 89 fe ff ff       	call   1090 <clock_gettime@plt>
    1207:	48 89 5c 24 18       	mov    QWORD PTR [rsp+0x18],rbx
    120c:	48 8d 74 24 30       	lea    rsi,[rsp+0x30]
    1211:	bf 01 00 00 00       	mov    edi,0x1
    1216:	e8 75 fe ff ff       	call   1090 <clock_gettime@plt>
    121b:	48 8b 44 24 38       	mov    rax,QWORD PTR [rsp+0x38]
    1220:	48 2b 44 24 28       	sub    rax,QWORD PTR [rsp+0x28]
    1225:	66 0f ef c0          	pxor   xmm0,xmm0
    1229:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    122e:	f2 0f 5e 05 1a 0e 00 	divsd  xmm0,QWORD PTR [rip+0xe1a]        # 2050 <_IO_stdin_used+0x50>
    1235:	00 
    1236:	48 8b 44 24 30       	mov    rax,QWORD PTR [rsp+0x30]
    123b:	48 2b 44 24 20       	sub    rax,QWORD PTR [rsp+0x20]
    1240:	66 0f ef c9          	pxor   xmm1,xmm1
    1244:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    1249:	f2 0f 58 c1          	addsd  xmm0,xmm1
    124d:	f2 0f 11 44 24 08    	movsd  QWORD PTR [rsp+0x8],xmm0
    1253:	48 8d 3d aa 0d 00 00 	lea    rdi,[rip+0xdaa]        # 2004 <_IO_stdin_used+0x4>
    125a:	e8 21 fe ff ff       	call   1080 <puts@plt>
    125f:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
    1264:	48 8d 35 b4 0d 00 00 	lea    rsi,[rip+0xdb4]        # 201f <_IO_stdin_used+0x1f>
    126b:	bf 02 00 00 00       	mov    edi,0x2
    1270:	b8 00 00 00 00       	mov    eax,0x0
    1275:	e8 36 fe ff ff       	call   10b0 <__printf_chk@plt>
    127a:	f2 0f 10 44 24 08    	movsd  xmm0,QWORD PTR [rsp+0x8]
    1280:	48 8d 35 a5 0d 00 00 	lea    rsi,[rip+0xda5]        # 202c <_IO_stdin_used+0x2c>
    1287:	bf 02 00 00 00       	mov    edi,0x2
    128c:	b8 01 00 00 00       	mov    eax,0x1
    1291:	e8 1a fe ff ff       	call   10b0 <__printf_chk@plt>
    1296:	ba 00 e1 f5 05       	mov    edx,0x5f5e100
    129b:	48 8d 35 9e 0d 00 00 	lea    rsi,[rip+0xd9e]        # 2040 <_IO_stdin_used+0x40>
    12a2:	bf 02 00 00 00       	mov    edi,0x2
    12a7:	b8 00 00 00 00       	mov    eax,0x0
    12ac:	e8 ff fd ff ff       	call   10b0 <__printf_chk@plt>
    12b1:	48 8b 44 24 48       	mov    rax,QWORD PTR [rsp+0x48]
    12b6:	64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
    12bd:	00 00 
    12bf:	75 0b                	jne    12cc <main+0xfa>
    12c1:	b8 00 00 00 00       	mov    eax,0x0
    12c6:	48 83 c4 50          	add    rsp,0x50
    12ca:	5b                   	pop    rbx
    12cb:	c3                   	ret
    12cc:	e8 cf fd ff ff       	call   10a0 <__stack_chk_fail@plt>

Disassembly of section .fini:

00000000000012d4 <_fini>:
    12d4:	f3 0f 1e fa          	endbr64
    12d8:	48 83 ec 08          	sub    rsp,0x8
    12dc:	48 83 c4 08          	add    rsp,0x8
    12e0:	c3                   	ret
