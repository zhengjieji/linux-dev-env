
build/07_function_inlining_Os:     file format elf64-x86-64


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

00000000000010c0 <main>:
    10c0:	f3 0f 1e fa          	endbr64
    10c4:	41 56                	push   r14
    10c6:	55                   	push   rbp
    10c7:	53                   	push   rbx
    10c8:	48 83 ec 30          	sub    rsp,0x30
    10cc:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    10d3:	00 00 
    10d5:	48 89 44 24 28       	mov    QWORD PTR [rsp+0x28],rax
    10da:	31 c0                	xor    eax,eax
    10dc:	48 8d 6c 24 08       	lea    rbp,[rsp+0x8]
    10e1:	48 89 ee             	mov    rsi,rbp
    10e4:	e8 4d 02 00 00       	call   1336 <benchmark_inlining>
    10e9:	bf 01 00 00 00       	mov    edi,0x1
    10ee:	48 89 c3             	mov    rbx,rax
    10f1:	48 89 04 24          	mov    QWORD PTR [rsp],rax
    10f5:	e8 96 ff ff ff       	call   1090 <clock_gettime@plt>
    10fa:	48 89 1c 24          	mov    QWORD PTR [rsp],rbx
    10fe:	48 8d 5c 24 18       	lea    rbx,[rsp+0x18]
    1103:	bf 01 00 00 00       	mov    edi,0x1
    1108:	48 89 de             	mov    rsi,rbx
    110b:	e8 80 ff ff ff       	call   1090 <clock_gettime@plt>
    1110:	48 8b 44 24 20       	mov    rax,QWORD PTR [rsp+0x20]
    1115:	48 2b 44 24 10       	sub    rax,QWORD PTR [rsp+0x10]
    111a:	48 89 ee             	mov    rsi,rbp
    111d:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    1122:	48 8b 44 24 18       	mov    rax,QWORD PTR [rsp+0x18]
    1127:	48 2b 44 24 08       	sub    rax,QWORD PTR [rsp+0x8]
    112c:	f2 0f 5e 05 5c 0f 00 	divsd  xmm0,QWORD PTR [rip+0xf5c]        # 2090 <_IO_stdin_used+0x90>
    1133:	00 
    1134:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    1139:	bf 01 00 00 00       	mov    edi,0x1
    113e:	f2 0f 58 c1          	addsd  xmm0,xmm1
    1142:	66 49 0f 7e c6       	movq   r14,xmm0
    1147:	e8 44 ff ff ff       	call   1090 <clock_gettime@plt>
    114c:	31 c0                	xor    eax,eax
    114e:	e8 05 02 00 00       	call   1358 <benchmark_larger_calls>
    1153:	48 89 de             	mov    rsi,rbx
    1156:	bf 01 00 00 00       	mov    edi,0x1
    115b:	48 89 04 24          	mov    QWORD PTR [rsp],rax
    115f:	e8 2c ff ff ff       	call   1090 <clock_gettime@plt>
    1164:	48 8b 44 24 20       	mov    rax,QWORD PTR [rsp+0x20]
    1169:	48 2b 44 24 10       	sub    rax,QWORD PTR [rsp+0x10]
    116e:	48 8d 3d 8f 0e 00 00 	lea    rdi,[rip+0xe8f]        # 2004 <_IO_stdin_used+0x4>
    1175:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    117a:	48 8b 44 24 18       	mov    rax,QWORD PTR [rsp+0x18]
    117f:	48 2b 44 24 08       	sub    rax,QWORD PTR [rsp+0x8]
    1184:	f2 0f 5e 05 04 0f 00 	divsd  xmm0,QWORD PTR [rip+0xf04]        # 2090 <_IO_stdin_used+0x90>
    118b:	00 
    118c:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    1191:	f2 0f 58 c1          	addsd  xmm0,xmm1
    1195:	66 48 0f 7e c3       	movq   rbx,xmm0
    119a:	e8 e1 fe ff ff       	call   1080 <puts@plt>
    119f:	ba 00 e1 f5 05       	mov    edx,0x5f5e100
    11a4:	66 49 0f 6e c6       	movq   xmm0,r14
    11a9:	b0 01                	mov    al,0x1
    11ab:	48 8d 35 69 0e 00 00 	lea    rsi,[rip+0xe69]        # 201b <_IO_stdin_used+0x1b>
    11b2:	bf 02 00 00 00       	mov    edi,0x2
    11b7:	e8 f4 fe ff ff       	call   10b0 <__printf_chk@plt>
    11bc:	ba 80 96 98 00       	mov    edx,0x989680
    11c1:	bf 02 00 00 00       	mov    edi,0x2
    11c6:	b0 01                	mov    al,0x1
    11c8:	48 8d 35 80 0e 00 00 	lea    rsi,[rip+0xe80]        # 204f <_IO_stdin_used+0x4f>
    11cf:	66 48 0f 6e c3       	movq   xmm0,rbx
    11d4:	e8 d7 fe ff ff       	call   10b0 <__printf_chk@plt>
    11d9:	48 8b 14 24          	mov    rdx,QWORD PTR [rsp]
    11dd:	31 c0                	xor    eax,eax
    11df:	bf 02 00 00 00       	mov    edi,0x2
    11e4:	48 8d 35 98 0e 00 00 	lea    rsi,[rip+0xe98]        # 2083 <_IO_stdin_used+0x83>
    11eb:	e8 c0 fe ff ff       	call   10b0 <__printf_chk@plt>
    11f0:	48 8b 44 24 28       	mov    rax,QWORD PTR [rsp+0x28]
    11f5:	64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
    11fc:	00 00 
    11fe:	74 05                	je     1205 <main+0x145>
    1200:	e8 9b fe ff ff       	call   10a0 <__stack_chk_fail@plt>
    1205:	48 83 c4 30          	add    rsp,0x30
    1209:	31 c0                	xor    eax,eax
    120b:	5b                   	pop    rbx
    120c:	5d                   	pop    rbp
    120d:	41 5e                	pop    r14
    120f:	c3                   	ret

0000000000001210 <_start>:
    1210:	f3 0f 1e fa          	endbr64
    1214:	31 ed                	xor    ebp,ebp
    1216:	49 89 d1             	mov    r9,rdx
    1219:	5e                   	pop    rsi
    121a:	48 89 e2             	mov    rdx,rsp
    121d:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
    1221:	50                   	push   rax
    1222:	54                   	push   rsp
    1223:	45 31 c0             	xor    r8d,r8d
    1226:	31 c9                	xor    ecx,ecx
    1228:	48 8d 3d 91 fe ff ff 	lea    rdi,[rip+0xfffffffffffffe91]        # 10c0 <main>
    122f:	ff 15 a3 2d 00 00    	call   QWORD PTR [rip+0x2da3]        # 3fd8 <__libc_start_main@GLIBC_2.34>
    1235:	f4                   	hlt
    1236:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    123d:	00 00 00 

0000000000001240 <deregister_tm_clones>:
    1240:	48 8d 3d c9 2d 00 00 	lea    rdi,[rip+0x2dc9]        # 4010 <__TMC_END__>
    1247:	48 8d 05 c2 2d 00 00 	lea    rax,[rip+0x2dc2]        # 4010 <__TMC_END__>
    124e:	48 39 f8             	cmp    rax,rdi
    1251:	74 15                	je     1268 <deregister_tm_clones+0x28>
    1253:	48 8b 05 86 2d 00 00 	mov    rax,QWORD PTR [rip+0x2d86]        # 3fe0 <_ITM_deregisterTMCloneTable@Base>
    125a:	48 85 c0             	test   rax,rax
    125d:	74 09                	je     1268 <deregister_tm_clones+0x28>
    125f:	ff e0                	jmp    rax
    1261:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    1268:	c3                   	ret
    1269:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001270 <register_tm_clones>:
    1270:	48 8d 3d 99 2d 00 00 	lea    rdi,[rip+0x2d99]        # 4010 <__TMC_END__>
    1277:	48 8d 35 92 2d 00 00 	lea    rsi,[rip+0x2d92]        # 4010 <__TMC_END__>
    127e:	48 29 fe             	sub    rsi,rdi
    1281:	48 89 f0             	mov    rax,rsi
    1284:	48 c1 ee 3f          	shr    rsi,0x3f
    1288:	48 c1 f8 03          	sar    rax,0x3
    128c:	48 01 c6             	add    rsi,rax
    128f:	48 d1 fe             	sar    rsi,1
    1292:	74 14                	je     12a8 <register_tm_clones+0x38>
    1294:	48 8b 05 55 2d 00 00 	mov    rax,QWORD PTR [rip+0x2d55]        # 3ff0 <_ITM_registerTMCloneTable@Base>
    129b:	48 85 c0             	test   rax,rax
    129e:	74 08                	je     12a8 <register_tm_clones+0x38>
    12a0:	ff e0                	jmp    rax
    12a2:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    12a8:	c3                   	ret
    12a9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000012b0 <__do_global_dtors_aux>:
    12b0:	f3 0f 1e fa          	endbr64
    12b4:	80 3d 55 2d 00 00 00 	cmp    BYTE PTR [rip+0x2d55],0x0        # 4010 <__TMC_END__>
    12bb:	75 2b                	jne    12e8 <__do_global_dtors_aux+0x38>
    12bd:	55                   	push   rbp
    12be:	48 83 3d 32 2d 00 00 	cmp    QWORD PTR [rip+0x2d32],0x0        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    12c5:	00 
    12c6:	48 89 e5             	mov    rbp,rsp
    12c9:	74 0c                	je     12d7 <__do_global_dtors_aux+0x27>
    12cb:	48 8b 3d 36 2d 00 00 	mov    rdi,QWORD PTR [rip+0x2d36]        # 4008 <__dso_handle>
    12d2:	e8 99 fd ff ff       	call   1070 <__cxa_finalize@plt>
    12d7:	e8 64 ff ff ff       	call   1240 <deregister_tm_clones>
    12dc:	c6 05 2d 2d 00 00 01 	mov    BYTE PTR [rip+0x2d2d],0x1        # 4010 <__TMC_END__>
    12e3:	5d                   	pop    rbp
    12e4:	c3                   	ret
    12e5:	0f 1f 00             	nop    DWORD PTR [rax]
    12e8:	c3                   	ret
    12e9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000012f0 <frame_dummy>:
    12f0:	f3 0f 1e fa          	endbr64
    12f4:	e9 77 ff ff ff       	jmp    1270 <register_tm_clones>

00000000000012f9 <compute_with_calls>:
    12f9:	f3 0f 1e fa          	endbr64
    12fd:	89 f8                	mov    eax,edi
    12ff:	0f af c7             	imul   eax,edi
    1302:	8d 44 b8 0a          	lea    eax,[rax+rdi*4+0xa]
    1306:	c3                   	ret

0000000000001307 <larger_function>:
    1307:	f3 0f 1e fa          	endbr64
    130b:	45 31 c9             	xor    r9d,r9d
    130e:	45 31 c0             	xor    r8d,r8d
    1311:	31 c9                	xor    ecx,ecx
    1313:	89 f0                	mov    eax,esi
    1315:	41 ff c0             	inc    r8d
    1318:	44 01 c9             	add    ecx,r9d
    131b:	41 01 f9             	add    r9d,edi
    131e:	99                   	cdq
    131f:	41 f7 f8             	idiv   r8d
    1322:	29 c1                	sub    ecx,eax
    1324:	41 83 f8 05          	cmp    r8d,0x5
    1328:	75 e9                	jne    1313 <larger_function+0xc>
    132a:	89 c8                	mov    eax,ecx
    132c:	c3                   	ret

000000000000132d <compute_with_larger_call>:
    132d:	f3 0f 1e fa          	endbr64
    1331:	8d 77 01             	lea    esi,[rdi+0x1]
    1334:	eb d1                	jmp    1307 <larger_function>

0000000000001336 <benchmark_inlining>:
    1336:	f3 0f 1e fa          	endbr64
    133a:	31 d2                	xor    edx,edx
    133c:	31 c9                	xor    ecx,ecx
    133e:	89 d7                	mov    edi,edx
    1340:	ff c2                	inc    edx
    1342:	e8 b2 ff ff ff       	call   12f9 <compute_with_calls>
    1347:	48 98                	cdqe
    1349:	48 01 c1             	add    rcx,rax
    134c:	81 fa 00 e1 f5 05    	cmp    edx,0x5f5e100
    1352:	75 ea                	jne    133e <benchmark_inlining+0x8>
    1354:	48 89 c8             	mov    rax,rcx
    1357:	c3                   	ret

0000000000001358 <benchmark_larger_calls>:
    1358:	f3 0f 1e fa          	endbr64
    135c:	31 ff                	xor    edi,edi
    135e:	45 31 d2             	xor    r10d,r10d
    1361:	e8 c7 ff ff ff       	call   132d <compute_with_larger_call>
    1366:	ff c7                	inc    edi
    1368:	48 98                	cdqe
    136a:	49 01 c2             	add    r10,rax
    136d:	81 ff 80 96 98 00    	cmp    edi,0x989680
    1373:	75 ec                	jne    1361 <benchmark_larger_calls+0x9>
    1375:	4c 89 d0             	mov    rax,r10
    1378:	c3                   	ret

Disassembly of section .fini:

000000000000137c <_fini>:
    137c:	f3 0f 1e fa          	endbr64
    1380:	48 83 ec 08          	sub    rsp,0x8
    1384:	48 83 c4 08          	add    rsp,0x8
    1388:	c3                   	ret
