
build/05_strength_reduction_O3:     file format elf64-x86-64


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
    10c4:	48 83 ec 58          	sub    rsp,0x58
    10c8:	66 0f 6f 2d 80 0f 00 	movdqa xmm5,XMMWORD PTR [rip+0xf80]        # 2050 <_IO_stdin_used+0x50>
    10cf:	00 
    10d0:	66 0f ef ff          	pxor   xmm7,xmm7
    10d4:	66 0f 6f 0d 84 0f 00 	movdqa xmm1,XMMWORD PTR [rip+0xf84]        # 2060 <_IO_stdin_used+0x60>
    10db:	00 
    10dc:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    10e3:	00 00 
    10e5:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
    10ea:	31 c0                	xor    eax,eax
    10ec:	66 0f 6f 15 7c 0f 00 	movdqa xmm2,XMMWORD PTR [rip+0xf7c]        # 2070 <_IO_stdin_used+0x70>
    10f3:	00 
    10f4:	66 45 0f ef c0       	pxor   xmm8,xmm8
    10f9:	66 0f 6f 1d 7f 0f 00 	movdqa xmm3,XMMWORD PTR [rip+0xf7f]        # 2080 <_IO_stdin_used+0x80>
    1100:	00 
    1101:	66 0f 6f f5          	movdqa xmm6,xmm5
    1105:	0f 1f 00             	nop    DWORD PTR [rax]
    1108:	66 0f 6f e6          	movdqa xmm4,xmm6
    110c:	83 c0 01             	add    eax,0x1
    110f:	66 0f fe f1          	paddd  xmm6,xmm1
    1113:	66 0f 6f c4          	movdqa xmm0,xmm4
    1117:	66 44 0f 6f cc       	movdqa xmm9,xmm4
    111c:	66 41 0f 72 f1 01    	pslld  xmm9,0x1
    1122:	66 0f 72 f0 02       	pslld  xmm0,0x2
    1127:	66 41 0f fe c1       	paddd  xmm0,xmm9
    112c:	66 44 0f 6f cc       	movdqa xmm9,xmm4
    1131:	66 41 0f 72 f1 03    	pslld  xmm9,0x3
    1137:	66 41 0f fe c1       	paddd  xmm0,xmm9
    113c:	66 44 0f 6f cc       	movdqa xmm9,xmm4
    1141:	66 41 0f 72 f1 04    	pslld  xmm9,0x4
    1147:	66 41 0f fe c1       	paddd  xmm0,xmm9
    114c:	66 44 0f 6f cc       	movdqa xmm9,xmm4
    1151:	66 41 0f 72 e1 01    	psrad  xmm9,0x1
    1157:	66 41 0f fe c1       	paddd  xmm0,xmm9
    115c:	66 44 0f 6f cc       	movdqa xmm9,xmm4
    1161:	66 0f db e2          	pand   xmm4,xmm2
    1165:	66 41 0f 72 e1 02    	psrad  xmm9,0x2
    116b:	66 41 0f fe c1       	paddd  xmm0,xmm9
    1170:	66 44 0f 6f cf       	movdqa xmm9,xmm7
    1175:	66 0f fe c4          	paddd  xmm0,xmm4
    1179:	66 0f fe c3          	paddd  xmm0,xmm3
    117d:	66 44 0f 66 c8       	pcmpgtd xmm9,xmm0
    1182:	66 0f 6f e0          	movdqa xmm4,xmm0
    1186:	66 41 0f 62 e1       	punpckldq xmm4,xmm9
    118b:	66 41 0f 6a c1       	punpckhdq xmm0,xmm9
    1190:	66 41 0f d4 e0       	paddq  xmm4,xmm8
    1195:	66 0f d4 e0          	paddq  xmm4,xmm0
    1199:	66 44 0f 6f c4       	movdqa xmm8,xmm4
    119e:	3d 40 78 7d 01       	cmp    eax,0x17d7840
    11a3:	0f 85 5f ff ff ff    	jne    1108 <main+0x48>
    11a9:	66 0f 6f c4          	movdqa xmm0,xmm4
    11ad:	48 8d 74 24 20       	lea    rsi,[rsp+0x20]
    11b2:	bf 01 00 00 00       	mov    edi,0x1
    11b7:	66 0f 73 d8 08       	psrldq xmm0,0x8
    11bc:	66 0f d4 c4          	paddq  xmm0,xmm4
    11c0:	66 0f d6 44 24 18    	movq   QWORD PTR [rsp+0x18],xmm0
    11c6:	e8 c5 fe ff ff       	call   1090 <clock_gettime@plt>
    11cb:	66 0f 6f 2d 7d 0e 00 	movdqa xmm5,XMMWORD PTR [rip+0xe7d]        # 2050 <_IO_stdin_used+0x50>
    11d2:	00 
    11d3:	31 c0                	xor    eax,eax
    11d5:	66 0f 6f 1d a3 0e 00 	movdqa xmm3,XMMWORD PTR [rip+0xea3]        # 2080 <_IO_stdin_used+0x80>
    11dc:	00 
    11dd:	66 0f 6f 15 8b 0e 00 	movdqa xmm2,XMMWORD PTR [rip+0xe8b]        # 2070 <_IO_stdin_used+0x70>
    11e4:	00 
    11e5:	66 0f 6f 0d 73 0e 00 	movdqa xmm1,XMMWORD PTR [rip+0xe73]        # 2060 <_IO_stdin_used+0x60>
    11ec:	00 
    11ed:	66 0f ef ff          	pxor   xmm7,xmm7
    11f1:	66 0f ef f6          	pxor   xmm6,xmm6
    11f5:	0f 1f 00             	nop    DWORD PTR [rax]
    11f8:	66 0f 6f e5          	movdqa xmm4,xmm5
    11fc:	83 c0 01             	add    eax,0x1
    11ff:	66 0f fe e9          	paddd  xmm5,xmm1
    1203:	66 0f 6f c4          	movdqa xmm0,xmm4
    1207:	66 44 0f 6f c4       	movdqa xmm8,xmm4
    120c:	66 41 0f 72 f0 01    	pslld  xmm8,0x1
    1212:	66 0f 72 f0 02       	pslld  xmm0,0x2
    1217:	66 41 0f fe c0       	paddd  xmm0,xmm8
    121c:	66 44 0f 6f c4       	movdqa xmm8,xmm4
    1221:	66 41 0f 72 f0 03    	pslld  xmm8,0x3
    1227:	66 41 0f fe c0       	paddd  xmm0,xmm8
    122c:	66 44 0f 6f c4       	movdqa xmm8,xmm4
    1231:	66 41 0f 72 f0 04    	pslld  xmm8,0x4
    1237:	66 41 0f fe c0       	paddd  xmm0,xmm8
    123c:	66 44 0f 6f c4       	movdqa xmm8,xmm4
    1241:	66 41 0f 72 e0 01    	psrad  xmm8,0x1
    1247:	66 41 0f fe c0       	paddd  xmm0,xmm8
    124c:	66 44 0f 6f c4       	movdqa xmm8,xmm4
    1251:	66 0f db e2          	pand   xmm4,xmm2
    1255:	66 41 0f 72 e0 02    	psrad  xmm8,0x2
    125b:	66 41 0f fe c0       	paddd  xmm0,xmm8
    1260:	66 44 0f 6f c6       	movdqa xmm8,xmm6
    1265:	66 0f fe c4          	paddd  xmm0,xmm4
    1269:	66 0f fe c3          	paddd  xmm0,xmm3
    126d:	66 44 0f 66 c0       	pcmpgtd xmm8,xmm0
    1272:	66 0f 6f e0          	movdqa xmm4,xmm0
    1276:	66 41 0f 62 e0       	punpckldq xmm4,xmm8
    127b:	66 41 0f 6a c0       	punpckhdq xmm0,xmm8
    1280:	66 0f d4 e7          	paddq  xmm4,xmm7
    1284:	66 0f 6f fc          	movdqa xmm7,xmm4
    1288:	66 0f d4 f8          	paddq  xmm7,xmm0
    128c:	3d 40 78 7d 01       	cmp    eax,0x17d7840
    1291:	0f 85 61 ff ff ff    	jne    11f8 <main+0x138>
    1297:	66 0f 6f c7          	movdqa xmm0,xmm7
    129b:	48 8d 74 24 30       	lea    rsi,[rsp+0x30]
    12a0:	bf 01 00 00 00       	mov    edi,0x1
    12a5:	66 0f 73 d8 08       	psrldq xmm0,0x8
    12aa:	66 0f d4 c7          	paddq  xmm0,xmm7
    12ae:	66 0f d6 44 24 18    	movq   QWORD PTR [rsp+0x18],xmm0
    12b4:	e8 d7 fd ff ff       	call   1090 <clock_gettime@plt>
    12b9:	48 8b 44 24 38       	mov    rax,QWORD PTR [rsp+0x38]
    12be:	66 0f ef c0          	pxor   xmm0,xmm0
    12c2:	48 2b 44 24 28       	sub    rax,QWORD PTR [rsp+0x28]
    12c7:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    12cc:	66 0f ef c9          	pxor   xmm1,xmm1
    12d0:	48 8b 44 24 30       	mov    rax,QWORD PTR [rsp+0x30]
    12d5:	48 2b 44 24 20       	sub    rax,QWORD PTR [rsp+0x20]
    12da:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    12df:	f2 0f 5e 05 a9 0d 00 	divsd  xmm0,QWORD PTR [rip+0xda9]        # 2090 <_IO_stdin_used+0x90>
    12e6:	00 
    12e7:	48 8d 3d 16 0d 00 00 	lea    rdi,[rip+0xd16]        # 2004 <_IO_stdin_used+0x4>
    12ee:	f2 0f 58 c1          	addsd  xmm0,xmm1
    12f2:	f2 0f 11 44 24 08    	movsd  QWORD PTR [rsp+0x8],xmm0
    12f8:	e8 83 fd ff ff       	call   1080 <puts@plt>
    12fd:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
    1302:	48 8d 35 13 0d 00 00 	lea    rsi,[rip+0xd13]        # 201c <_IO_stdin_used+0x1c>
    1309:	31 c0                	xor    eax,eax
    130b:	bf 02 00 00 00       	mov    edi,0x2
    1310:	e8 9b fd ff ff       	call   10b0 <__printf_chk@plt>
    1315:	f2 0f 10 44 24 08    	movsd  xmm0,QWORD PTR [rsp+0x8]
    131b:	bf 02 00 00 00       	mov    edi,0x2
    1320:	48 8d 35 02 0d 00 00 	lea    rsi,[rip+0xd02]        # 2029 <_IO_stdin_used+0x29>
    1327:	b8 01 00 00 00       	mov    eax,0x1
    132c:	e8 7f fd ff ff       	call   10b0 <__printf_chk@plt>
    1331:	31 c0                	xor    eax,eax
    1333:	ba 00 e1 f5 05       	mov    edx,0x5f5e100
    1338:	48 8d 35 fe 0c 00 00 	lea    rsi,[rip+0xcfe]        # 203d <_IO_stdin_used+0x3d>
    133f:	bf 02 00 00 00       	mov    edi,0x2
    1344:	e8 67 fd ff ff       	call   10b0 <__printf_chk@plt>
    1349:	48 8b 44 24 48       	mov    rax,QWORD PTR [rsp+0x48]
    134e:	64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
    1355:	00 00 
    1357:	75 07                	jne    1360 <main+0x2a0>
    1359:	31 c0                	xor    eax,eax
    135b:	48 83 c4 58          	add    rsp,0x58
    135f:	c3                   	ret
    1360:	e8 3b fd ff ff       	call   10a0 <__stack_chk_fail@plt>
    1365:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    136c:	00 00 00 
    136f:	90                   	nop

0000000000001370 <_start>:
    1370:	f3 0f 1e fa          	endbr64
    1374:	31 ed                	xor    ebp,ebp
    1376:	49 89 d1             	mov    r9,rdx
    1379:	5e                   	pop    rsi
    137a:	48 89 e2             	mov    rdx,rsp
    137d:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
    1381:	50                   	push   rax
    1382:	54                   	push   rsp
    1383:	45 31 c0             	xor    r8d,r8d
    1386:	31 c9                	xor    ecx,ecx
    1388:	48 8d 3d 31 fd ff ff 	lea    rdi,[rip+0xfffffffffffffd31]        # 10c0 <main>
    138f:	ff 15 43 2c 00 00    	call   QWORD PTR [rip+0x2c43]        # 3fd8 <__libc_start_main@GLIBC_2.34>
    1395:	f4                   	hlt
    1396:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    139d:	00 00 00 

00000000000013a0 <deregister_tm_clones>:
    13a0:	48 8d 3d 69 2c 00 00 	lea    rdi,[rip+0x2c69]        # 4010 <__TMC_END__>
    13a7:	48 8d 05 62 2c 00 00 	lea    rax,[rip+0x2c62]        # 4010 <__TMC_END__>
    13ae:	48 39 f8             	cmp    rax,rdi
    13b1:	74 15                	je     13c8 <deregister_tm_clones+0x28>
    13b3:	48 8b 05 26 2c 00 00 	mov    rax,QWORD PTR [rip+0x2c26]        # 3fe0 <_ITM_deregisterTMCloneTable@Base>
    13ba:	48 85 c0             	test   rax,rax
    13bd:	74 09                	je     13c8 <deregister_tm_clones+0x28>
    13bf:	ff e0                	jmp    rax
    13c1:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    13c8:	c3                   	ret
    13c9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000013d0 <register_tm_clones>:
    13d0:	48 8d 3d 39 2c 00 00 	lea    rdi,[rip+0x2c39]        # 4010 <__TMC_END__>
    13d7:	48 8d 35 32 2c 00 00 	lea    rsi,[rip+0x2c32]        # 4010 <__TMC_END__>
    13de:	48 29 fe             	sub    rsi,rdi
    13e1:	48 89 f0             	mov    rax,rsi
    13e4:	48 c1 ee 3f          	shr    rsi,0x3f
    13e8:	48 c1 f8 03          	sar    rax,0x3
    13ec:	48 01 c6             	add    rsi,rax
    13ef:	48 d1 fe             	sar    rsi,1
    13f2:	74 14                	je     1408 <register_tm_clones+0x38>
    13f4:	48 8b 05 f5 2b 00 00 	mov    rax,QWORD PTR [rip+0x2bf5]        # 3ff0 <_ITM_registerTMCloneTable@Base>
    13fb:	48 85 c0             	test   rax,rax
    13fe:	74 08                	je     1408 <register_tm_clones+0x38>
    1400:	ff e0                	jmp    rax
    1402:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    1408:	c3                   	ret
    1409:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001410 <__do_global_dtors_aux>:
    1410:	f3 0f 1e fa          	endbr64
    1414:	80 3d f5 2b 00 00 00 	cmp    BYTE PTR [rip+0x2bf5],0x0        # 4010 <__TMC_END__>
    141b:	75 2b                	jne    1448 <__do_global_dtors_aux+0x38>
    141d:	55                   	push   rbp
    141e:	48 83 3d d2 2b 00 00 	cmp    QWORD PTR [rip+0x2bd2],0x0        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    1425:	00 
    1426:	48 89 e5             	mov    rbp,rsp
    1429:	74 0c                	je     1437 <__do_global_dtors_aux+0x27>
    142b:	48 8b 3d d6 2b 00 00 	mov    rdi,QWORD PTR [rip+0x2bd6]        # 4008 <__dso_handle>
    1432:	e8 39 fc ff ff       	call   1070 <__cxa_finalize@plt>
    1437:	e8 64 ff ff ff       	call   13a0 <deregister_tm_clones>
    143c:	c6 05 cd 2b 00 00 01 	mov    BYTE PTR [rip+0x2bcd],0x1        # 4010 <__TMC_END__>
    1443:	5d                   	pop    rbp
    1444:	c3                   	ret
    1445:	0f 1f 00             	nop    DWORD PTR [rax]
    1448:	c3                   	ret
    1449:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001450 <frame_dummy>:
    1450:	f3 0f 1e fa          	endbr64
    1454:	e9 77 ff ff ff       	jmp    13d0 <register_tm_clones>
    1459:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001460 <compute_with_expensive_ops>:
    1460:	f3 0f 1e fa          	endbr64
    1464:	8d 14 bd 00 00 00 00 	lea    edx,[rdi*4+0x0]
    146b:	89 f8                	mov    eax,edi
    146d:	8d 14 7a             	lea    edx,[rdx+rdi*2]
    1470:	8d 0c fa             	lea    ecx,[rdx+rdi*8]
    1473:	89 fa                	mov    edx,edi
    1475:	c1 e2 04             	shl    edx,0x4
    1478:	01 ca                	add    edx,ecx
    147a:	89 f9                	mov    ecx,edi
    147c:	c1 e9 1f             	shr    ecx,0x1f
    147f:	01 f9                	add    ecx,edi
    1481:	d1 f9                	sar    ecx,1
    1483:	01 d1                	add    ecx,edx
    1485:	85 ff                	test   edi,edi
    1487:	8d 57 03             	lea    edx,[rdi+0x3]
    148a:	0f 49 d7             	cmovns edx,edi
    148d:	c1 fa 02             	sar    edx,0x2
    1490:	01 ca                	add    edx,ecx
    1492:	89 f9                	mov    ecx,edi
    1494:	c1 f9 1f             	sar    ecx,0x1f
    1497:	c1 e9 1d             	shr    ecx,0x1d
    149a:	01 c8                	add    eax,ecx
    149c:	83 e0 07             	and    eax,0x7
    149f:	29 c8                	sub    eax,ecx
    14a1:	8d 84 02 87 00 00 00 	lea    eax,[rdx+rax*1+0x87]
    14a8:	c3                   	ret
    14a9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000014b0 <compute_optimized>:
    14b0:	f3 0f 1e fa          	endbr64
    14b4:	8d 04 fd 00 00 00 00 	lea    eax,[rdi*8+0x0]
    14bb:	8d 14 7f             	lea    edx,[rdi+rdi*2]
    14be:	8d 14 50             	lea    edx,[rax+rdx*2]
    14c1:	89 f8                	mov    eax,edi
    14c3:	c1 e0 04             	shl    eax,0x4
    14c6:	01 d0                	add    eax,edx
    14c8:	89 fa                	mov    edx,edi
    14ca:	d1 fa                	sar    edx,1
    14cc:	01 c2                	add    edx,eax
    14ce:	89 f8                	mov    eax,edi
    14d0:	83 e7 07             	and    edi,0x7
    14d3:	c1 f8 02             	sar    eax,0x2
    14d6:	01 d0                	add    eax,edx
    14d8:	8d 84 38 87 00 00 00 	lea    eax,[rax+rdi*1+0x87]
    14df:	c3                   	ret

00000000000014e0 <benchmark_strength_reduction>:
    14e0:	f3 0f 1e fa          	endbr64
    14e4:	66 0f 6f 15 64 0b 00 	movdqa xmm2,XMMWORD PTR [rip+0xb64]        # 2050 <_IO_stdin_used+0x50>
    14eb:	00 
    14ec:	31 c0                	xor    eax,eax
    14ee:	66 0f ef ff          	pxor   xmm7,xmm7
    14f2:	66 0f 6f 35 66 0b 00 	movdqa xmm6,XMMWORD PTR [rip+0xb66]        # 2060 <_IO_stdin_used+0x60>
    14f9:	00 
    14fa:	66 0f 6f 2d 6e 0b 00 	movdqa xmm5,XMMWORD PTR [rip+0xb6e]        # 2070 <_IO_stdin_used+0x70>
    1501:	00 
    1502:	66 0f 6f 25 76 0b 00 	movdqa xmm4,XMMWORD PTR [rip+0xb76]        # 2080 <_IO_stdin_used+0x80>
    1509:	00 
    150a:	66 0f ef db          	pxor   xmm3,xmm3
    150e:	66 90                	xchg   ax,ax
    1510:	66 0f 6f ca          	movdqa xmm1,xmm2
    1514:	83 c0 01             	add    eax,0x1
    1517:	66 0f fe d6          	paddd  xmm2,xmm6
    151b:	66 0f 6f c1          	movdqa xmm0,xmm1
    151f:	66 44 0f 6f c1       	movdqa xmm8,xmm1
    1524:	66 41 0f 72 f0 01    	pslld  xmm8,0x1
    152a:	66 0f 72 f0 02       	pslld  xmm0,0x2
    152f:	66 41 0f fe c0       	paddd  xmm0,xmm8
    1534:	66 44 0f 6f c1       	movdqa xmm8,xmm1
    1539:	66 41 0f 72 f0 03    	pslld  xmm8,0x3
    153f:	66 41 0f fe c0       	paddd  xmm0,xmm8
    1544:	66 44 0f 6f c1       	movdqa xmm8,xmm1
    1549:	66 41 0f 72 f0 04    	pslld  xmm8,0x4
    154f:	66 41 0f fe c0       	paddd  xmm0,xmm8
    1554:	66 44 0f 6f c1       	movdqa xmm8,xmm1
    1559:	66 41 0f 72 e0 01    	psrad  xmm8,0x1
    155f:	66 41 0f fe c0       	paddd  xmm0,xmm8
    1564:	66 44 0f 6f c1       	movdqa xmm8,xmm1
    1569:	66 0f db cd          	pand   xmm1,xmm5
    156d:	66 41 0f 72 e0 02    	psrad  xmm8,0x2
    1573:	66 41 0f fe c0       	paddd  xmm0,xmm8
    1578:	66 44 0f 6f c3       	movdqa xmm8,xmm3
    157d:	66 0f fe c1          	paddd  xmm0,xmm1
    1581:	66 0f fe c4          	paddd  xmm0,xmm4
    1585:	66 44 0f 66 c0       	pcmpgtd xmm8,xmm0
    158a:	66 0f 6f c8          	movdqa xmm1,xmm0
    158e:	66 41 0f 62 c8       	punpckldq xmm1,xmm8
    1593:	66 41 0f 6a c0       	punpckhdq xmm0,xmm8
    1598:	66 0f d4 cf          	paddq  xmm1,xmm7
    159c:	66 0f 6f f9          	movdqa xmm7,xmm1
    15a0:	66 0f d4 f8          	paddq  xmm7,xmm0
    15a4:	3d 40 78 7d 01       	cmp    eax,0x17d7840
    15a9:	0f 85 61 ff ff ff    	jne    1510 <benchmark_strength_reduction+0x30>
    15af:	66 0f 6f c7          	movdqa xmm0,xmm7
    15b3:	66 0f 73 d8 08       	psrldq xmm0,0x8
    15b8:	66 0f d4 f8          	paddq  xmm7,xmm0
    15bc:	66 48 0f 7e f8       	movq   rax,xmm7
    15c1:	c3                   	ret

Disassembly of section .fini:

00000000000015c4 <_fini>:
    15c4:	f3 0f 1e fa          	endbr64
    15c8:	48 83 ec 08          	sub    rsp,0x8
    15cc:	48 83 c4 08          	add    rsp,0x8
    15d0:	c3                   	ret
