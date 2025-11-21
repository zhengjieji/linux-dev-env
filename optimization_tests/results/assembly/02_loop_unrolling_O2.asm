
build/02_loop_unrolling_O2:     file format elf64-x86-64


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
    10c4:	53                   	push   rbx
    10c5:	bf 01 00 00 00       	mov    edi,0x1
    10ca:	48 83 ec 50          	sub    rsp,0x50
    10ce:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    10d5:	00 00 
    10d7:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
    10dc:	31 c0                	xor    eax,eax
    10de:	48 8d 74 24 20       	lea    rsi,[rsp+0x20]
    10e3:	e8 48 03 00 00       	call   1430 <benchmark_loop_unrolling>
    10e8:	48 89 c3             	mov    rbx,rax
    10eb:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    10f0:	e8 9b ff ff ff       	call   1090 <clock_gettime@plt>
    10f5:	48 8d 74 24 30       	lea    rsi,[rsp+0x30]
    10fa:	bf 01 00 00 00       	mov    edi,0x1
    10ff:	48 89 5c 24 18       	mov    QWORD PTR [rsp+0x18],rbx
    1104:	e8 87 ff ff ff       	call   1090 <clock_gettime@plt>
    1109:	48 8b 44 24 38       	mov    rax,QWORD PTR [rsp+0x38]
    110e:	66 0f ef c0          	pxor   xmm0,xmm0
    1112:	48 2b 44 24 28       	sub    rax,QWORD PTR [rsp+0x28]
    1117:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    111c:	66 0f ef c9          	pxor   xmm1,xmm1
    1120:	48 8b 44 24 30       	mov    rax,QWORD PTR [rsp+0x30]
    1125:	48 2b 44 24 20       	sub    rax,QWORD PTR [rsp+0x20]
    112a:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    112f:	f2 0f 5e 05 29 0f 00 	divsd  xmm0,QWORD PTR [rip+0xf29]        # 2060 <_IO_stdin_used+0x60>
    1136:	00 
    1137:	48 8d 3d c6 0e 00 00 	lea    rdi,[rip+0xec6]        # 2004 <_IO_stdin_used+0x4>
    113e:	f2 0f 58 c1          	addsd  xmm0,xmm1
    1142:	f2 0f 11 44 24 08    	movsd  QWORD PTR [rsp+0x8],xmm0
    1148:	e8 33 ff ff ff       	call   1080 <puts@plt>
    114d:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
    1152:	48 8d 35 bf 0e 00 00 	lea    rsi,[rip+0xebf]        # 2018 <_IO_stdin_used+0x18>
    1159:	31 c0                	xor    eax,eax
    115b:	bf 02 00 00 00       	mov    edi,0x2
    1160:	e8 4b ff ff ff       	call   10b0 <__printf_chk@plt>
    1165:	f2 0f 10 44 24 08    	movsd  xmm0,QWORD PTR [rsp+0x8]
    116b:	bf 02 00 00 00       	mov    edi,0x2
    1170:	48 8d 35 ae 0e 00 00 	lea    rsi,[rip+0xeae]        # 2025 <_IO_stdin_used+0x25>
    1177:	b8 01 00 00 00       	mov    eax,0x1
    117c:	e8 2f ff ff ff       	call   10b0 <__printf_chk@plt>
    1181:	31 c0                	xor    eax,eax
    1183:	ba 80 96 98 00       	mov    edx,0x989680
    1188:	48 8d 35 aa 0e 00 00 	lea    rsi,[rip+0xeaa]        # 2039 <_IO_stdin_used+0x39>
    118f:	bf 02 00 00 00       	mov    edi,0x2
    1194:	e8 17 ff ff ff       	call   10b0 <__printf_chk@plt>
    1199:	48 8b 44 24 48       	mov    rax,QWORD PTR [rsp+0x48]
    119e:	64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
    11a5:	00 00 
    11a7:	75 08                	jne    11b1 <main+0xf1>
    11a9:	48 83 c4 50          	add    rsp,0x50
    11ad:	31 c0                	xor    eax,eax
    11af:	5b                   	pop    rbx
    11b0:	c3                   	ret
    11b1:	e8 ea fe ff ff       	call   10a0 <__stack_chk_fail@plt>
    11b6:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    11bd:	00 00 00 

00000000000011c0 <_start>:
    11c0:	f3 0f 1e fa          	endbr64
    11c4:	31 ed                	xor    ebp,ebp
    11c6:	49 89 d1             	mov    r9,rdx
    11c9:	5e                   	pop    rsi
    11ca:	48 89 e2             	mov    rdx,rsp
    11cd:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
    11d1:	50                   	push   rax
    11d2:	54                   	push   rsp
    11d3:	45 31 c0             	xor    r8d,r8d
    11d6:	31 c9                	xor    ecx,ecx
    11d8:	48 8d 3d e1 fe ff ff 	lea    rdi,[rip+0xfffffffffffffee1]        # 10c0 <main>
    11df:	ff 15 f3 2d 00 00    	call   QWORD PTR [rip+0x2df3]        # 3fd8 <__libc_start_main@GLIBC_2.34>
    11e5:	f4                   	hlt
    11e6:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    11ed:	00 00 00 

00000000000011f0 <deregister_tm_clones>:
    11f0:	48 8d 3d 19 2e 00 00 	lea    rdi,[rip+0x2e19]        # 4010 <__TMC_END__>
    11f7:	48 8d 05 12 2e 00 00 	lea    rax,[rip+0x2e12]        # 4010 <__TMC_END__>
    11fe:	48 39 f8             	cmp    rax,rdi
    1201:	74 15                	je     1218 <deregister_tm_clones+0x28>
    1203:	48 8b 05 d6 2d 00 00 	mov    rax,QWORD PTR [rip+0x2dd6]        # 3fe0 <_ITM_deregisterTMCloneTable@Base>
    120a:	48 85 c0             	test   rax,rax
    120d:	74 09                	je     1218 <deregister_tm_clones+0x28>
    120f:	ff e0                	jmp    rax
    1211:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    1218:	c3                   	ret
    1219:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001220 <register_tm_clones>:
    1220:	48 8d 3d e9 2d 00 00 	lea    rdi,[rip+0x2de9]        # 4010 <__TMC_END__>
    1227:	48 8d 35 e2 2d 00 00 	lea    rsi,[rip+0x2de2]        # 4010 <__TMC_END__>
    122e:	48 29 fe             	sub    rsi,rdi
    1231:	48 89 f0             	mov    rax,rsi
    1234:	48 c1 ee 3f          	shr    rsi,0x3f
    1238:	48 c1 f8 03          	sar    rax,0x3
    123c:	48 01 c6             	add    rsi,rax
    123f:	48 d1 fe             	sar    rsi,1
    1242:	74 14                	je     1258 <register_tm_clones+0x38>
    1244:	48 8b 05 a5 2d 00 00 	mov    rax,QWORD PTR [rip+0x2da5]        # 3ff0 <_ITM_registerTMCloneTable@Base>
    124b:	48 85 c0             	test   rax,rax
    124e:	74 08                	je     1258 <register_tm_clones+0x38>
    1250:	ff e0                	jmp    rax
    1252:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    1258:	c3                   	ret
    1259:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001260 <__do_global_dtors_aux>:
    1260:	f3 0f 1e fa          	endbr64
    1264:	80 3d a5 2d 00 00 00 	cmp    BYTE PTR [rip+0x2da5],0x0        # 4010 <__TMC_END__>
    126b:	75 2b                	jne    1298 <__do_global_dtors_aux+0x38>
    126d:	55                   	push   rbp
    126e:	48 83 3d 82 2d 00 00 	cmp    QWORD PTR [rip+0x2d82],0x0        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    1275:	00 
    1276:	48 89 e5             	mov    rbp,rsp
    1279:	74 0c                	je     1287 <__do_global_dtors_aux+0x27>
    127b:	48 8b 3d 86 2d 00 00 	mov    rdi,QWORD PTR [rip+0x2d86]        # 4008 <__dso_handle>
    1282:	e8 e9 fd ff ff       	call   1070 <__cxa_finalize@plt>
    1287:	e8 64 ff ff ff       	call   11f0 <deregister_tm_clones>
    128c:	c6 05 7d 2d 00 00 01 	mov    BYTE PTR [rip+0x2d7d],0x1        # 4010 <__TMC_END__>
    1293:	5d                   	pop    rbp
    1294:	c3                   	ret
    1295:	0f 1f 00             	nop    DWORD PTR [rax]
    1298:	c3                   	ret
    1299:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000012a0 <frame_dummy>:
    12a0:	f3 0f 1e fa          	endbr64
    12a4:	e9 77 ff ff ff       	jmp    1220 <register_tm_clones>
    12a9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000012b0 <sum_small_array>:
    12b0:	f3 0f 1e fa          	endbr64
    12b4:	f3 0f 6f 4f 10       	movdqu xmm1,XMMWORD PTR [rdi+0x10]
    12b9:	f3 0f 6f 07          	movdqu xmm0,XMMWORD PTR [rdi]
    12bd:	66 0f fe c1          	paddd  xmm0,xmm1
    12c1:	66 0f 6f c8          	movdqa xmm1,xmm0
    12c5:	66 0f 73 d9 08       	psrldq xmm1,0x8
    12ca:	66 0f fe c1          	paddd  xmm0,xmm1
    12ce:	66 0f 6f c8          	movdqa xmm1,xmm0
    12d2:	66 0f 73 d9 04       	psrldq xmm1,0x4
    12d7:	66 0f fe c1          	paddd  xmm0,xmm1
    12db:	66 0f 7e c0          	movd   eax,xmm0
    12df:	c3                   	ret

00000000000012e0 <process_array>:
    12e0:	f3 0f 1e fa          	endbr64
    12e4:	66 0f 6f 1d 64 0d 00 	movdqa xmm3,XMMWORD PTR [rip+0xd64]        # 2050 <_IO_stdin_used+0x50>
    12eb:	00 
    12ec:	66 0f ef c9          	pxor   xmm1,xmm1
    12f0:	f3 0f 6f 07          	movdqu xmm0,XMMWORD PTR [rdi]
    12f4:	66 0f 6f e9          	movdqa xmm5,xmm1
    12f8:	66 0f 6f f9          	movdqa xmm7,xmm1
    12fc:	f3 0f 6f 67 10       	movdqu xmm4,XMMWORD PTR [rdi+0x10]
    1301:	66 0f 66 eb          	pcmpgtd xmm5,xmm3
    1305:	66 0f 66 f8          	pcmpgtd xmm7,xmm0
    1309:	66 0f 6f d0          	movdqa xmm2,xmm0
    130d:	66 0f f4 d3          	pmuludq xmm2,xmm3
    1311:	66 0f 6f f0          	movdqa xmm6,xmm0
    1315:	66 0f 72 e6 1f       	psrad  xmm6,0x1f
    131a:	66 44 0f 6f c5       	movdqa xmm8,xmm5
    131f:	66 0f f4 fb          	pmuludq xmm7,xmm3
    1323:	66 44 0f 6f cd       	movdqa xmm9,xmm5
    1328:	66 44 0f f4 c0       	pmuludq xmm8,xmm0
    132d:	66 41 0f d4 f8       	paddq  xmm7,xmm8
    1332:	66 44 0f 6f c1       	movdqa xmm8,xmm1
    1337:	66 0f 73 f7 20       	psllq  xmm7,0x20
    133c:	66 0f d4 d7          	paddq  xmm2,xmm7
    1340:	66 0f 6f f8          	movdqa xmm7,xmm0
    1344:	66 0f 73 d7 20       	psrlq  xmm7,0x20
    1349:	66 44 0f 66 c7       	pcmpgtd xmm8,xmm7
    134e:	66 44 0f f4 cf       	pmuludq xmm9,xmm7
    1353:	66 0f f4 fb          	pmuludq xmm7,xmm3
    1357:	66 44 0f f4 c3       	pmuludq xmm8,xmm3
    135c:	66 45 0f d4 c1       	paddq  xmm8,xmm9
    1361:	66 41 0f 73 f0 20    	psllq  xmm8,0x20
    1367:	66 41 0f d4 f8       	paddq  xmm7,xmm8
    136c:	66 44 0f 6f c5       	movdqa xmm8,xmm5
    1371:	0f c6 d7 dd          	shufps xmm2,xmm7,0xdd
    1375:	66 0f 6f f9          	movdqa xmm7,xmm1
    1379:	66 0f 70 d2 d8       	pshufd xmm2,xmm2,0xd8
    137e:	66 0f 66 fc          	pcmpgtd xmm7,xmm4
    1382:	66 44 0f f4 c4       	pmuludq xmm8,xmm4
    1387:	66 0f fe d0          	paddd  xmm2,xmm0
    138b:	66 0f fa f2          	psubd  xmm6,xmm2
    138f:	66 0f 72 f0 01       	pslld  xmm0,0x1
    1394:	66 0f 6f d4          	movdqa xmm2,xmm4
    1398:	66 0f f4 d3          	pmuludq xmm2,xmm3
    139c:	66 0f fe f0          	paddd  xmm6,xmm0
    13a0:	66 0f 6f c4          	movdqa xmm0,xmm4
    13a4:	66 0f f4 fb          	pmuludq xmm7,xmm3
    13a8:	66 0f 72 f0 01       	pslld  xmm0,0x1
    13ad:	66 0f fe f0          	paddd  xmm6,xmm0
    13b1:	66 0f 6f c4          	movdqa xmm0,xmm4
    13b5:	66 0f 72 e0 1f       	psrad  xmm0,0x1f
    13ba:	66 41 0f d4 f8       	paddq  xmm7,xmm8
    13bf:	66 0f 73 f7 20       	psllq  xmm7,0x20
    13c4:	66 0f d4 d7          	paddq  xmm2,xmm7
    13c8:	66 0f 6f fc          	movdqa xmm7,xmm4
    13cc:	66 0f 73 d7 20       	psrlq  xmm7,0x20
    13d1:	66 0f 66 cf          	pcmpgtd xmm1,xmm7
    13d5:	66 0f f4 ef          	pmuludq xmm5,xmm7
    13d9:	66 0f f4 fb          	pmuludq xmm7,xmm3
    13dd:	66 0f f4 cb          	pmuludq xmm1,xmm3
    13e1:	66 0f d4 cd          	paddq  xmm1,xmm5
    13e5:	66 0f 73 f1 20       	psllq  xmm1,0x20
    13ea:	66 0f d4 f9          	paddq  xmm7,xmm1
    13ee:	66 0f 6f ca          	movdqa xmm1,xmm2
    13f2:	0f c6 cf dd          	shufps xmm1,xmm7,0xdd
    13f6:	66 0f 70 c9 d8       	pshufd xmm1,xmm1,0xd8
    13fb:	66 0f fe cc          	paddd  xmm1,xmm4
    13ff:	66 0f fa c1          	psubd  xmm0,xmm1
    1403:	66 0f fe c6          	paddd  xmm0,xmm6
    1407:	66 0f 6f c8          	movdqa xmm1,xmm0
    140b:	66 0f 73 d9 08       	psrldq xmm1,0x8
    1410:	66 0f fe c1          	paddd  xmm0,xmm1
    1414:	66 0f 6f c8          	movdqa xmm1,xmm0
    1418:	66 0f 73 d9 04       	psrldq xmm1,0x4
    141d:	66 0f fe c1          	paddd  xmm0,xmm1
    1421:	66 0f 7e c0          	movd   eax,xmm0
    1425:	c3                   	ret
    1426:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    142d:	00 00 00 

0000000000001430 <benchmark_loop_unrolling>:
    1430:	f3 0f 1e fa          	endbr64
    1434:	b8 80 96 98 00       	mov    eax,0x989680
    1439:	31 d2                	xor    edx,edx
    143b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    1440:	48 81 c2 b8 00 00 00 	add    rdx,0xb8
    1447:	83 e8 02             	sub    eax,0x2
    144a:	75 f4                	jne    1440 <benchmark_loop_unrolling+0x10>
    144c:	48 89 d0             	mov    rax,rdx
    144f:	c3                   	ret

Disassembly of section .fini:

0000000000001450 <_fini>:
    1450:	f3 0f 1e fa          	endbr64
    1454:	48 83 ec 08          	sub    rsp,0x8
    1458:	48 83 c4 08          	add    rsp,0x8
    145c:	c3                   	ret
