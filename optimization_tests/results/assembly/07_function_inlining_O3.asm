
build/07_function_inlining_O3:     file format elf64-x86-64


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
    10c6:	66 0f ef e4          	pxor   xmm4,xmm4
    10ca:	66 0f ef ff          	pxor   xmm7,xmm7
    10ce:	55                   	push   rbp
    10cf:	53                   	push   rbx
    10d0:	48 83 ec 70          	sub    rsp,0x70
    10d4:	66 0f 6f 35 c4 0f 00 	movdqa xmm6,XMMWORD PTR [rip+0xfc4]        # 20a0 <_IO_stdin_used+0xa0>
    10db:	00 
    10dc:	66 44 0f 6f 2d cb 0f 	movdqa xmm13,XMMWORD PTR [rip+0xfcb]        # 20b0 <_IO_stdin_used+0xb0>
    10e3:	00 00 
    10e5:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    10ec:	00 00 
    10ee:	48 89 44 24 68       	mov    QWORD PTR [rsp+0x68],rax
    10f3:	31 c0                	xor    eax,eax
    10f5:	66 0f 6f 15 c3 0f 00 	movdqa xmm2,XMMWORD PTR [rip+0xfc3]        # 20c0 <_IO_stdin_used+0xc0>
    10fc:	00 
    10fd:	0f 1f 00             	nop    DWORD PTR [rax]
    1100:	66 0f 6f ce          	movdqa xmm1,xmm6
    1104:	83 c0 01             	add    eax,0x1
    1107:	66 41 0f fe f5       	paddd  xmm6,xmm13
    110c:	66 0f 6f d9          	movdqa xmm3,xmm1
    1110:	66 0f 6f e9          	movdqa xmm5,xmm1
    1114:	66 0f 6f c1          	movdqa xmm0,xmm1
    1118:	66 0f 73 d3 20       	psrlq  xmm3,0x20
    111d:	66 0f f4 e9          	pmuludq xmm5,xmm1
    1121:	66 0f fe ca          	paddd  xmm1,xmm2
    1125:	66 0f f4 db          	pmuludq xmm3,xmm3
    1129:	66 0f 72 f0 01       	pslld  xmm0,0x1
    112e:	66 0f 72 f1 01       	pslld  xmm1,0x1
    1133:	66 0f 70 ed 08       	pshufd xmm5,xmm5,0x8
    1138:	66 0f 70 db 08       	pshufd xmm3,xmm3,0x8
    113d:	66 0f 62 eb          	punpckldq xmm5,xmm3
    1141:	66 0f 6f df          	movdqa xmm3,xmm7
    1145:	66 0f fe c5          	paddd  xmm0,xmm5
    1149:	66 0f fe c1          	paddd  xmm0,xmm1
    114d:	66 0f 66 d8          	pcmpgtd xmm3,xmm0
    1151:	66 0f 6f c8          	movdqa xmm1,xmm0
    1155:	66 0f 62 cb          	punpckldq xmm1,xmm3
    1159:	66 0f 6a c3          	punpckhdq xmm0,xmm3
    115d:	66 0f d4 cc          	paddq  xmm1,xmm4
    1161:	66 0f 6f e1          	movdqa xmm4,xmm1
    1165:	66 0f d4 e0          	paddq  xmm4,xmm0
    1169:	3d 40 78 7d 01       	cmp    eax,0x17d7840
    116e:	75 90                	jne    1100 <main+0x40>
    1170:	66 0f 6f c4          	movdqa xmm0,xmm4
    1174:	48 8d 5c 24 40       	lea    rbx,[rsp+0x40]
    1179:	bf 01 00 00 00       	mov    edi,0x1
    117e:	66 0f 73 d8 08       	psrldq xmm0,0x8
    1183:	48 89 de             	mov    rsi,rbx
    1186:	66 0f d4 c4          	paddq  xmm0,xmm4
    118a:	66 0f d6 44 24 38    	movq   QWORD PTR [rsp+0x38],xmm0
    1190:	e8 fb fe ff ff       	call   1090 <clock_gettime@plt>
    1195:	66 0f ef f6          	pxor   xmm6,xmm6
    1199:	31 c0                	xor    eax,eax
    119b:	66 0f ef ed          	pxor   xmm5,xmm5
    119f:	66 0f 6f 25 f9 0e 00 	movdqa xmm4,XMMWORD PTR [rip+0xef9]        # 20a0 <_IO_stdin_used+0xa0>
    11a6:	00 
    11a7:	66 0f 6f 15 11 0f 00 	movdqa xmm2,XMMWORD PTR [rip+0xf11]        # 20c0 <_IO_stdin_used+0xc0>
    11ae:	00 
    11af:	66 0f 6f fe          	movdqa xmm7,xmm6
    11b3:	66 44 0f 6f 2d f4 0e 	movdqa xmm13,XMMWORD PTR [rip+0xef4]        # 20b0 <_IO_stdin_used+0xb0>
    11ba:	00 00 
    11bc:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    11c0:	66 0f 6f cc          	movdqa xmm1,xmm4
    11c4:	83 c0 01             	add    eax,0x1
    11c7:	66 41 0f fe e5       	paddd  xmm4,xmm13
    11cc:	66 0f 6f d9          	movdqa xmm3,xmm1
    11d0:	66 0f 6f c1          	movdqa xmm0,xmm1
    11d4:	66 0f 73 d3 20       	psrlq  xmm3,0x20
    11d9:	66 0f f4 c1          	pmuludq xmm0,xmm1
    11dd:	66 0f f4 db          	pmuludq xmm3,xmm3
    11e1:	66 0f 70 c0 08       	pshufd xmm0,xmm0,0x8
    11e6:	66 0f 70 db 08       	pshufd xmm3,xmm3,0x8
    11eb:	66 0f 62 c3          	punpckldq xmm0,xmm3
    11ef:	66 0f 6f d9          	movdqa xmm3,xmm1
    11f3:	66 0f fe ca          	paddd  xmm1,xmm2
    11f7:	66 0f 72 f3 01       	pslld  xmm3,0x1
    11fc:	66 0f 72 f1 01       	pslld  xmm1,0x1
    1201:	66 0f fe c3          	paddd  xmm0,xmm3
    1205:	66 0f fe c1          	paddd  xmm0,xmm1
    1209:	66 0f 6f cd          	movdqa xmm1,xmm5
    120d:	66 0f 66 c8          	pcmpgtd xmm1,xmm0
    1211:	66 0f 6f f0          	movdqa xmm6,xmm0
    1215:	66 0f 62 f1          	punpckldq xmm6,xmm1
    1219:	66 0f 6a c1          	punpckhdq xmm0,xmm1
    121d:	66 0f d4 f7          	paddq  xmm6,xmm7
    1221:	66 0f 6f fe          	movdqa xmm7,xmm6
    1225:	66 0f d4 f8          	paddq  xmm7,xmm0
    1229:	3d 40 78 7d 01       	cmp    eax,0x17d7840
    122e:	75 90                	jne    11c0 <main+0x100>
    1230:	66 0f 6f c7          	movdqa xmm0,xmm7
    1234:	48 8d 6c 24 50       	lea    rbp,[rsp+0x50]
    1239:	bf 01 00 00 00       	mov    edi,0x1
    123e:	66 0f 73 d8 08       	psrldq xmm0,0x8
    1243:	48 89 ee             	mov    rsi,rbp
    1246:	66 0f d4 c7          	paddq  xmm0,xmm7
    124a:	66 0f d6 44 24 38    	movq   QWORD PTR [rsp+0x38],xmm0
    1250:	e8 3b fe ff ff       	call   1090 <clock_gettime@plt>
    1255:	66 0f ef c0          	pxor   xmm0,xmm0
    1259:	66 0f ef c9          	pxor   xmm1,xmm1
    125d:	48 89 de             	mov    rsi,rbx
    1260:	48 8b 44 24 58       	mov    rax,QWORD PTR [rsp+0x58]
    1265:	48 2b 44 24 48       	sub    rax,QWORD PTR [rsp+0x48]
    126a:	bf 01 00 00 00       	mov    edi,0x1
    126f:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    1274:	48 8b 44 24 50       	mov    rax,QWORD PTR [rsp+0x50]
    1279:	48 2b 44 24 40       	sub    rax,QWORD PTR [rsp+0x40]
    127e:	f2 0f 5e 05 8a 0e 00 	divsd  xmm0,QWORD PTR [rip+0xe8a]        # 2110 <_IO_stdin_used+0x110>
    1285:	00 
    1286:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    128b:	f2 0f 58 c1          	addsd  xmm0,xmm1
    128f:	66 49 0f 7e c6       	movq   r14,xmm0
    1294:	e8 f7 fd ff ff       	call   1090 <clock_gettime@plt>
    1299:	66 45 0f ef e4       	pxor   xmm12,xmm12
    129e:	31 c0                	xor    eax,eax
    12a0:	66 44 0f 6f 15 37 0e 	movdqa xmm10,XMMWORD PTR [rip+0xe37]        # 20e0 <_IO_stdin_used+0xe0>
    12a7:	00 00 
    12a9:	66 41 0f 6f e4       	movdqa xmm4,xmm12
    12ae:	66 45 0f ef f6       	pxor   xmm14,xmm14
    12b3:	66 44 0f 6f 0d 34 0e 	movdqa xmm9,XMMWORD PTR [rip+0xe34]        # 20f0 <_IO_stdin_used+0xf0>
    12ba:	00 00 
    12bc:	66 44 0f 6f 1d db 0d 	movdqa xmm11,XMMWORD PTR [rip+0xddb]        # 20a0 <_IO_stdin_used+0xa0>
    12c3:	00 00 
    12c5:	66 44 0f 6f 2d e2 0d 	movdqa xmm13,XMMWORD PTR [rip+0xde2]        # 20b0 <_IO_stdin_used+0xb0>
    12cc:	00 00 
    12ce:	66 41 0f 66 e2       	pcmpgtd xmm4,xmm10
    12d3:	0f 29 64 24 10       	movaps XMMWORD PTR [rsp+0x10],xmm4
    12d8:	66 41 0f 6f e4       	movdqa xmm4,xmm12
    12dd:	66 41 0f 66 e1       	pcmpgtd xmm4,xmm9
    12e2:	0f 29 64 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm4
    12e7:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
    12ee:	00 00 
    12f0:	66 0f 6f 0d d8 0d 00 	movdqa xmm1,XMMWORD PTR [rip+0xdd8]        # 20d0 <_IO_stdin_used+0xd0>
    12f7:	00 
    12f8:	66 41 0f 6f fb       	movdqa xmm7,xmm11
    12fd:	66 41 0f 6f e4       	movdqa xmm4,xmm12
    1302:	83 c0 01             	add    eax,0x1
    1305:	66 44 0f 6f c7       	movdqa xmm8,xmm7
    130a:	66 45 0f fe dd       	paddd  xmm11,xmm13
    130f:	66 0f fe cf          	paddd  xmm1,xmm7
    1313:	66 41 0f 72 f0 01    	pslld  xmm8,0x1
    1319:	66 0f 6f c1          	movdqa xmm0,xmm1
    131d:	66 0f 66 e1          	pcmpgtd xmm4,xmm1
    1321:	66 0f 6f e9          	movdqa xmm5,xmm1
    1325:	66 0f 72 e0 01       	psrad  xmm0,0x1
    132a:	66 0f ef 05 ce 0d 00 	pxor   xmm0,XMMWORD PTR [rip+0xdce]        # 2100 <_IO_stdin_used+0x100>
    1331:	00 
    1332:	66 41 0f f4 ea       	pmuludq xmm5,xmm10
    1337:	66 41 0f fe c0       	paddd  xmm0,xmm8
    133c:	66 0f 6f d4          	movdqa xmm2,xmm4
    1340:	66 44 0f fe c7       	paddd  xmm8,xmm7
    1345:	0f 29 04 24          	movaps XMMWORD PTR [rsp],xmm0
    1349:	66 0f 6f 44 24 10    	movdqa xmm0,XMMWORD PTR [rsp+0x10]
    134f:	66 41 0f f4 d2       	pmuludq xmm2,xmm10
    1354:	66 0f 72 f7 02       	pslld  xmm7,0x2
    1359:	66 41 0f f4 e1       	pmuludq xmm4,xmm9
    135e:	66 0f 6f d8          	movdqa xmm3,xmm0
    1362:	66 44 0f 6f f8       	movdqa xmm15,xmm0
    1367:	66 0f f4 d9          	pmuludq xmm3,xmm1
    136b:	66 0f d4 d3          	paddq  xmm2,xmm3
    136f:	66 41 0f 6f dc       	movdqa xmm3,xmm12
    1374:	66 0f 73 f2 20       	psllq  xmm2,0x20
    1379:	66 0f d4 ea          	paddq  xmm5,xmm2
    137d:	66 0f 6f d1          	movdqa xmm2,xmm1
    1381:	66 0f 73 d2 20       	psrlq  xmm2,0x20
    1386:	66 0f 66 da          	pcmpgtd xmm3,xmm2
    138a:	66 44 0f f4 fa       	pmuludq xmm15,xmm2
    138f:	66 0f 6f c2          	movdqa xmm0,xmm2
    1393:	66 41 0f f4 c2       	pmuludq xmm0,xmm10
    1398:	66 0f 6f f3          	movdqa xmm6,xmm3
    139c:	66 41 0f f4 d9       	pmuludq xmm3,xmm9
    13a1:	66 41 0f f4 f2       	pmuludq xmm6,xmm10
    13a6:	66 41 0f d4 f7       	paddq  xmm6,xmm15
    13ab:	66 0f 73 f6 20       	psllq  xmm6,0x20
    13b0:	66 0f d4 f0          	paddq  xmm6,xmm0
    13b4:	66 0f 6f 04 24       	movdqa xmm0,XMMWORD PTR [rsp]
    13b9:	0f c6 ee dd          	shufps xmm5,xmm6,0xdd
    13bd:	66 0f 70 ed d8       	pshufd xmm5,xmm5,0xd8
    13c2:	66 0f 6f 74 24 20    	movdqa xmm6,XMMWORD PTR [rsp+0x20]
    13c8:	66 0f fa c5          	psubd  xmm0,xmm5
    13cc:	66 0f 6f e9          	movdqa xmm5,xmm1
    13d0:	66 0f 72 e5 02       	psrad  xmm5,0x2
    13d5:	66 41 0f fe c0       	paddd  xmm0,xmm8
    13da:	66 0f fa c5          	psubd  xmm0,xmm5
    13de:	66 0f 6f ef          	movdqa xmm5,xmm7
    13e2:	66 0f 6f f8          	movdqa xmm7,xmm0
    13e6:	66 0f 6f c6          	movdqa xmm0,xmm6
    13ea:	66 0f f4 c1          	pmuludq xmm0,xmm1
    13ee:	66 41 0f f4 c9       	pmuludq xmm1,xmm9
    13f3:	66 0f fe fd          	paddd  xmm7,xmm5
    13f7:	66 0f d4 e0          	paddq  xmm4,xmm0
    13fb:	66 0f 6f c6          	movdqa xmm0,xmm6
    13ff:	66 0f f4 c2          	pmuludq xmm0,xmm2
    1403:	66 41 0f f4 d1       	pmuludq xmm2,xmm9
    1408:	66 0f 73 f4 20       	psllq  xmm4,0x20
    140d:	66 0f d4 cc          	paddq  xmm1,xmm4
    1411:	66 0f d4 d8          	paddq  xmm3,xmm0
    1415:	66 0f 73 f3 20       	psllq  xmm3,0x20
    141a:	66 0f d4 d3          	paddq  xmm2,xmm3
    141e:	0f c6 ca dd          	shufps xmm1,xmm2,0xdd
    1422:	66 0f 70 c9 d8       	pshufd xmm1,xmm1,0xd8
    1427:	66 0f 72 e1 01       	psrad  xmm1,0x1
    142c:	66 0f fa f9          	psubd  xmm7,xmm1
    1430:	66 41 0f 6f cc       	movdqa xmm1,xmm12
    1435:	66 0f 66 cf          	pcmpgtd xmm1,xmm7
    1439:	66 0f 6f c7          	movdqa xmm0,xmm7
    143d:	66 0f 62 c1          	punpckldq xmm0,xmm1
    1441:	66 0f 6a f9          	punpckhdq xmm7,xmm1
    1445:	66 41 0f d4 c6       	paddq  xmm0,xmm14
    144a:	66 0f d4 c7          	paddq  xmm0,xmm7
    144e:	66 44 0f 6f f0       	movdqa xmm14,xmm0
    1453:	3d a0 25 26 00       	cmp    eax,0x2625a0
    1458:	0f 85 92 fe ff ff    	jne    12f0 <main+0x230>
    145e:	66 0f 73 d8 08       	psrldq xmm0,0x8
    1463:	48 89 ee             	mov    rsi,rbp
    1466:	bf 01 00 00 00       	mov    edi,0x1
    146b:	66 41 0f d4 c6       	paddq  xmm0,xmm14
    1470:	66 0f d6 44 24 38    	movq   QWORD PTR [rsp+0x38],xmm0
    1476:	e8 15 fc ff ff       	call   1090 <clock_gettime@plt>
    147b:	48 8b 44 24 58       	mov    rax,QWORD PTR [rsp+0x58]
    1480:	66 0f ef c0          	pxor   xmm0,xmm0
    1484:	48 2b 44 24 48       	sub    rax,QWORD PTR [rsp+0x48]
    1489:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    148e:	66 0f ef c9          	pxor   xmm1,xmm1
    1492:	48 8b 44 24 50       	mov    rax,QWORD PTR [rsp+0x50]
    1497:	48 2b 44 24 40       	sub    rax,QWORD PTR [rsp+0x40]
    149c:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    14a1:	f2 0f 5e 05 67 0c 00 	divsd  xmm0,QWORD PTR [rip+0xc67]        # 2110 <_IO_stdin_used+0x110>
    14a8:	00 
    14a9:	48 8d 3d 54 0b 00 00 	lea    rdi,[rip+0xb54]        # 2004 <_IO_stdin_used+0x4>
    14b0:	f2 0f 58 c1          	addsd  xmm0,xmm1
    14b4:	f2 0f 11 04 24       	movsd  QWORD PTR [rsp],xmm0
    14b9:	e8 c2 fb ff ff       	call   1080 <puts@plt>
    14be:	ba 00 e1 f5 05       	mov    edx,0x5f5e100
    14c3:	66 49 0f 6e c6       	movq   xmm0,r14
    14c8:	48 8d 35 59 0b 00 00 	lea    rsi,[rip+0xb59]        # 2028 <_IO_stdin_used+0x28>
    14cf:	bf 02 00 00 00       	mov    edi,0x2
    14d4:	b8 01 00 00 00       	mov    eax,0x1
    14d9:	e8 d2 fb ff ff       	call   10b0 <__printf_chk@plt>
    14de:	f2 0f 10 04 24       	movsd  xmm0,QWORD PTR [rsp]
    14e3:	ba 80 96 98 00       	mov    edx,0x989680
    14e8:	48 8d 35 71 0b 00 00 	lea    rsi,[rip+0xb71]        # 2060 <_IO_stdin_used+0x60>
    14ef:	bf 02 00 00 00       	mov    edi,0x2
    14f4:	b8 01 00 00 00       	mov    eax,0x1
    14f9:	e8 b2 fb ff ff       	call   10b0 <__printf_chk@plt>
    14fe:	48 8b 54 24 38       	mov    rdx,QWORD PTR [rsp+0x38]
    1503:	31 c0                	xor    eax,eax
    1505:	48 8d 35 0f 0b 00 00 	lea    rsi,[rip+0xb0f]        # 201b <_IO_stdin_used+0x1b>
    150c:	bf 02 00 00 00       	mov    edi,0x2
    1511:	e8 9a fb ff ff       	call   10b0 <__printf_chk@plt>
    1516:	48 8b 44 24 68       	mov    rax,QWORD PTR [rsp+0x68]
    151b:	64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
    1522:	00 00 
    1524:	75 0b                	jne    1531 <main+0x471>
    1526:	48 83 c4 70          	add    rsp,0x70
    152a:	31 c0                	xor    eax,eax
    152c:	5b                   	pop    rbx
    152d:	5d                   	pop    rbp
    152e:	41 5e                	pop    r14
    1530:	c3                   	ret
    1531:	e8 6a fb ff ff       	call   10a0 <__stack_chk_fail@plt>
    1536:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    153d:	00 00 00 

0000000000001540 <_start>:
    1540:	f3 0f 1e fa          	endbr64
    1544:	31 ed                	xor    ebp,ebp
    1546:	49 89 d1             	mov    r9,rdx
    1549:	5e                   	pop    rsi
    154a:	48 89 e2             	mov    rdx,rsp
    154d:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
    1551:	50                   	push   rax
    1552:	54                   	push   rsp
    1553:	45 31 c0             	xor    r8d,r8d
    1556:	31 c9                	xor    ecx,ecx
    1558:	48 8d 3d 61 fb ff ff 	lea    rdi,[rip+0xfffffffffffffb61]        # 10c0 <main>
    155f:	ff 15 73 2a 00 00    	call   QWORD PTR [rip+0x2a73]        # 3fd8 <__libc_start_main@GLIBC_2.34>
    1565:	f4                   	hlt
    1566:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    156d:	00 00 00 

0000000000001570 <deregister_tm_clones>:
    1570:	48 8d 3d 99 2a 00 00 	lea    rdi,[rip+0x2a99]        # 4010 <__TMC_END__>
    1577:	48 8d 05 92 2a 00 00 	lea    rax,[rip+0x2a92]        # 4010 <__TMC_END__>
    157e:	48 39 f8             	cmp    rax,rdi
    1581:	74 15                	je     1598 <deregister_tm_clones+0x28>
    1583:	48 8b 05 56 2a 00 00 	mov    rax,QWORD PTR [rip+0x2a56]        # 3fe0 <_ITM_deregisterTMCloneTable@Base>
    158a:	48 85 c0             	test   rax,rax
    158d:	74 09                	je     1598 <deregister_tm_clones+0x28>
    158f:	ff e0                	jmp    rax
    1591:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    1598:	c3                   	ret
    1599:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000015a0 <register_tm_clones>:
    15a0:	48 8d 3d 69 2a 00 00 	lea    rdi,[rip+0x2a69]        # 4010 <__TMC_END__>
    15a7:	48 8d 35 62 2a 00 00 	lea    rsi,[rip+0x2a62]        # 4010 <__TMC_END__>
    15ae:	48 29 fe             	sub    rsi,rdi
    15b1:	48 89 f0             	mov    rax,rsi
    15b4:	48 c1 ee 3f          	shr    rsi,0x3f
    15b8:	48 c1 f8 03          	sar    rax,0x3
    15bc:	48 01 c6             	add    rsi,rax
    15bf:	48 d1 fe             	sar    rsi,1
    15c2:	74 14                	je     15d8 <register_tm_clones+0x38>
    15c4:	48 8b 05 25 2a 00 00 	mov    rax,QWORD PTR [rip+0x2a25]        # 3ff0 <_ITM_registerTMCloneTable@Base>
    15cb:	48 85 c0             	test   rax,rax
    15ce:	74 08                	je     15d8 <register_tm_clones+0x38>
    15d0:	ff e0                	jmp    rax
    15d2:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    15d8:	c3                   	ret
    15d9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000015e0 <__do_global_dtors_aux>:
    15e0:	f3 0f 1e fa          	endbr64
    15e4:	80 3d 25 2a 00 00 00 	cmp    BYTE PTR [rip+0x2a25],0x0        # 4010 <__TMC_END__>
    15eb:	75 2b                	jne    1618 <__do_global_dtors_aux+0x38>
    15ed:	55                   	push   rbp
    15ee:	48 83 3d 02 2a 00 00 	cmp    QWORD PTR [rip+0x2a02],0x0        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    15f5:	00 
    15f6:	48 89 e5             	mov    rbp,rsp
    15f9:	74 0c                	je     1607 <__do_global_dtors_aux+0x27>
    15fb:	48 8b 3d 06 2a 00 00 	mov    rdi,QWORD PTR [rip+0x2a06]        # 4008 <__dso_handle>
    1602:	e8 69 fa ff ff       	call   1070 <__cxa_finalize@plt>
    1607:	e8 64 ff ff ff       	call   1570 <deregister_tm_clones>
    160c:	c6 05 fd 29 00 00 01 	mov    BYTE PTR [rip+0x29fd],0x1        # 4010 <__TMC_END__>
    1613:	5d                   	pop    rbp
    1614:	c3                   	ret
    1615:	0f 1f 00             	nop    DWORD PTR [rax]
    1618:	c3                   	ret
    1619:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001620 <frame_dummy>:
    1620:	f3 0f 1e fa          	endbr64
    1624:	e9 77 ff ff ff       	jmp    15a0 <register_tm_clones>
    1629:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001630 <compute_with_calls>:
    1630:	f3 0f 1e fa          	endbr64
    1634:	89 f8                	mov    eax,edi
    1636:	0f af c7             	imul   eax,edi
    1639:	8d 44 b8 0a          	lea    eax,[rax+rdi*4+0xa]
    163d:	c3                   	ret
    163e:	66 90                	xchg   ax,ax

0000000000001640 <larger_function>:
    1640:	f3 0f 1e fa          	endbr64
    1644:	89 f0                	mov    eax,esi
    1646:	89 fe                	mov    esi,edi
    1648:	8d 0c 3f             	lea    ecx,[rdi+rdi*1]
    164b:	89 c2                	mov    edx,eax
    164d:	29 c6                	sub    esi,eax
    164f:	41 89 c0             	mov    r8d,eax
    1652:	c1 ea 1f             	shr    edx,0x1f
    1655:	41 c1 f8 1f          	sar    r8d,0x1f
    1659:	01 c2                	add    edx,eax
    165b:	d1 fa                	sar    edx,1
    165d:	29 d6                	sub    esi,edx
    165f:	48 63 d0             	movsxd rdx,eax
    1662:	4c 69 ca 56 55 55 55 	imul   r9,rdx,0x55555556
    1669:	01 ce                	add    esi,ecx
    166b:	01 f9                	add    ecx,edi
    166d:	49 c1 e9 20          	shr    r9,0x20
    1671:	45 29 c1             	sub    r9d,r8d
    1674:	44 29 ce             	sub    esi,r9d
    1677:	01 f1                	add    ecx,esi
    1679:	85 c0                	test   eax,eax
    167b:	8d 70 03             	lea    esi,[rax+0x3]
    167e:	0f 48 c6             	cmovs  eax,esi
    1681:	48 69 d2 67 66 66 66 	imul   rdx,rdx,0x66666667
    1688:	c1 f8 02             	sar    eax,0x2
    168b:	29 c1                	sub    ecx,eax
    168d:	48 c1 fa 21          	sar    rdx,0x21
    1691:	8d 04 b9             	lea    eax,[rcx+rdi*4]
    1694:	44 29 c2             	sub    edx,r8d
    1697:	29 d0                	sub    eax,edx
    1699:	c3                   	ret
    169a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

00000000000016a0 <compute_with_larger_call>:
    16a0:	f3 0f 1e fa          	endbr64
    16a4:	89 fe                	mov    esi,edi
    16a6:	8d 7f 01             	lea    edi,[rdi+0x1]
    16a9:	48 63 d7             	movsxd rdx,edi
    16ac:	89 f8                	mov    eax,edi
    16ae:	8d 0c 36             	lea    ecx,[rsi+rsi*1]
    16b1:	41 89 f8             	mov    r8d,edi
    16b4:	4c 69 ca 56 55 55 55 	imul   r9,rdx,0x55555556
    16bb:	c1 e8 1f             	shr    eax,0x1f
    16be:	41 c1 f8 1f          	sar    r8d,0x1f
    16c2:	01 f8                	add    eax,edi
    16c4:	d1 f8                	sar    eax,1
    16c6:	49 c1 e9 20          	shr    r9,0x20
    16ca:	f7 d0                	not    eax
    16cc:	01 c8                	add    eax,ecx
    16ce:	45 29 c1             	sub    r9d,r8d
    16d1:	01 f1                	add    ecx,esi
    16d3:	44 29 c8             	sub    eax,r9d
    16d6:	01 c1                	add    ecx,eax
    16d8:	85 ff                	test   edi,edi
    16da:	8d 46 04             	lea    eax,[rsi+0x4]
    16dd:	0f 49 c7             	cmovns eax,edi
    16e0:	48 69 d2 67 66 66 66 	imul   rdx,rdx,0x66666667
    16e7:	c1 f8 02             	sar    eax,0x2
    16ea:	29 c1                	sub    ecx,eax
    16ec:	48 c1 fa 21          	sar    rdx,0x21
    16f0:	8d 04 b1             	lea    eax,[rcx+rsi*4]
    16f3:	44 29 c2             	sub    edx,r8d
    16f6:	29 d0                	sub    eax,edx
    16f8:	c3                   	ret
    16f9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001700 <benchmark_inlining>:
    1700:	f3 0f 1e fa          	endbr64
    1704:	66 0f 6f 1d 94 09 00 	movdqa xmm3,XMMWORD PTR [rip+0x994]        # 20a0 <_IO_stdin_used+0xa0>
    170b:	00 
    170c:	66 0f 6f 35 9c 09 00 	movdqa xmm6,XMMWORD PTR [rip+0x99c]        # 20b0 <_IO_stdin_used+0xb0>
    1713:	00 
    1714:	31 c0                	xor    eax,eax
    1716:	66 0f ef ff          	pxor   xmm7,xmm7
    171a:	66 0f 6f 2d 9e 09 00 	movdqa xmm5,XMMWORD PTR [rip+0x99e]        # 20c0 <_IO_stdin_used+0xc0>
    1721:	00 
    1722:	66 0f ef e4          	pxor   xmm4,xmm4
    1726:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    172d:	00 00 00 
    1730:	66 0f 6f cb          	movdqa xmm1,xmm3
    1734:	83 c0 01             	add    eax,0x1
    1737:	66 0f fe de          	paddd  xmm3,xmm6
    173b:	66 0f 6f d1          	movdqa xmm2,xmm1
    173f:	66 0f 6f c1          	movdqa xmm0,xmm1
    1743:	66 0f 73 d2 20       	psrlq  xmm2,0x20
    1748:	66 0f f4 c1          	pmuludq xmm0,xmm1
    174c:	66 0f f4 d2          	pmuludq xmm2,xmm2
    1750:	66 0f 70 c0 08       	pshufd xmm0,xmm0,0x8
    1755:	66 0f 70 d2 08       	pshufd xmm2,xmm2,0x8
    175a:	66 0f 62 c2          	punpckldq xmm0,xmm2
    175e:	66 0f 6f d1          	movdqa xmm2,xmm1
    1762:	66 0f fe cd          	paddd  xmm1,xmm5
    1766:	66 0f 72 f2 01       	pslld  xmm2,0x1
    176b:	66 0f 72 f1 01       	pslld  xmm1,0x1
    1770:	66 0f fe c2          	paddd  xmm0,xmm2
    1774:	66 0f 6f d4          	movdqa xmm2,xmm4
    1778:	66 0f fe c1          	paddd  xmm0,xmm1
    177c:	66 0f 66 d0          	pcmpgtd xmm2,xmm0
    1780:	66 0f 6f c8          	movdqa xmm1,xmm0
    1784:	66 0f 62 ca          	punpckldq xmm1,xmm2
    1788:	66 0f 6a c2          	punpckhdq xmm0,xmm2
    178c:	66 0f d4 cf          	paddq  xmm1,xmm7
    1790:	66 0f 6f f9          	movdqa xmm7,xmm1
    1794:	66 0f d4 f8          	paddq  xmm7,xmm0
    1798:	3d 40 78 7d 01       	cmp    eax,0x17d7840
    179d:	75 91                	jne    1730 <benchmark_inlining+0x30>
    179f:	66 0f 6f c7          	movdqa xmm0,xmm7
    17a3:	66 0f 73 d8 08       	psrldq xmm0,0x8
    17a8:	66 0f d4 f8          	paddq  xmm7,xmm0
    17ac:	66 48 0f 7e f8       	movq   rax,xmm7
    17b1:	c3                   	ret
    17b2:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    17b9:	00 00 00 00 
    17bd:	0f 1f 00             	nop    DWORD PTR [rax]

00000000000017c0 <benchmark_larger_calls>:
    17c0:	f3 0f 1e fa          	endbr64
    17c4:	66 45 0f ef e4       	pxor   xmm12,xmm12
    17c9:	31 c0                	xor    eax,eax
    17cb:	66 45 0f ef c9       	pxor   xmm9,xmm9
    17d0:	66 44 0f 6f 1d 07 09 	movdqa xmm11,XMMWORD PTR [rip+0x907]        # 20e0 <_IO_stdin_used+0xe0>
    17d7:	00 00 
    17d9:	66 44 0f 6f 15 0e 09 	movdqa xmm10,XMMWORD PTR [rip+0x90e]        # 20f0 <_IO_stdin_used+0xf0>
    17e0:	00 00 
    17e2:	66 41 0f 6f e4       	movdqa xmm4,xmm12
    17e7:	66 44 0f 6f 2d b0 08 	movdqa xmm13,XMMWORD PTR [rip+0x8b0]        # 20a0 <_IO_stdin_used+0xa0>
    17ee:	00 00 
    17f0:	66 41 0f 66 e3       	pcmpgtd xmm4,xmm11
    17f5:	0f 29 64 24 d8       	movaps XMMWORD PTR [rsp-0x28],xmm4
    17fa:	66 41 0f 6f e4       	movdqa xmm4,xmm12
    17ff:	66 41 0f 66 e2       	pcmpgtd xmm4,xmm10
    1804:	0f 29 64 24 e8       	movaps XMMWORD PTR [rsp-0x18],xmm4
    1809:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    1810:	66 0f 6f 0d b8 08 00 	movdqa xmm1,XMMWORD PTR [rip+0x8b8]        # 20d0 <_IO_stdin_used+0xd0>
    1817:	00 
    1818:	66 41 0f 6f fd       	movdqa xmm7,xmm13
    181d:	66 41 0f 6f e4       	movdqa xmm4,xmm12
    1822:	83 c0 01             	add    eax,0x1
    1825:	66 44 0f 6f 74 24 d8 	movdqa xmm14,XMMWORD PTR [rsp-0x28]
    182c:	66 44 0f 6f c7       	movdqa xmm8,xmm7
    1831:	66 44 0f fe 2d 76 08 	paddd  xmm13,XMMWORD PTR [rip+0x876]        # 20b0 <_IO_stdin_used+0xb0>
    1838:	00 00 
    183a:	66 0f fe cf          	paddd  xmm1,xmm7
    183e:	66 41 0f 72 f0 01    	pslld  xmm8,0x1
    1844:	66 0f 66 e1          	pcmpgtd xmm4,xmm1
    1848:	66 41 0f 6f de       	movdqa xmm3,xmm14
    184d:	66 0f 6f e9          	movdqa xmm5,xmm1
    1851:	66 0f f4 d9          	pmuludq xmm3,xmm1
    1855:	66 41 0f f4 eb       	pmuludq xmm5,xmm11
    185a:	66 45 0f 6f fe       	movdqa xmm15,xmm14
    185f:	66 0f 6f c1          	movdqa xmm0,xmm1
    1863:	66 0f 6f d4          	movdqa xmm2,xmm4
    1867:	66 0f 72 e0 01       	psrad  xmm0,0x1
    186c:	66 0f ef 05 8c 08 00 	pxor   xmm0,XMMWORD PTR [rip+0x88c]        # 2100 <_IO_stdin_used+0x100>
    1873:	00 
    1874:	66 41 0f f4 d3       	pmuludq xmm2,xmm11
    1879:	66 41 0f f4 e2       	pmuludq xmm4,xmm10
    187e:	66 41 0f fe c0       	paddd  xmm0,xmm8
    1883:	66 44 0f fe c7       	paddd  xmm8,xmm7
    1888:	66 0f 72 f7 02       	pslld  xmm7,0x2
    188d:	66 0f d4 d3          	paddq  xmm2,xmm3
    1891:	66 41 0f 6f dc       	movdqa xmm3,xmm12
    1896:	66 0f 73 f2 20       	psllq  xmm2,0x20
    189b:	66 0f d4 ea          	paddq  xmm5,xmm2
    189f:	66 0f 6f d1          	movdqa xmm2,xmm1
    18a3:	66 0f 73 d2 20       	psrlq  xmm2,0x20
    18a8:	66 0f 66 da          	pcmpgtd xmm3,xmm2
    18ac:	66 44 0f f4 fa       	pmuludq xmm15,xmm2
    18b1:	66 44 0f 6f f2       	movdqa xmm14,xmm2
    18b6:	66 45 0f f4 f3       	pmuludq xmm14,xmm11
    18bb:	66 0f 6f f3          	movdqa xmm6,xmm3
    18bf:	66 41 0f f4 da       	pmuludq xmm3,xmm10
    18c4:	66 41 0f f4 f3       	pmuludq xmm6,xmm11
    18c9:	66 41 0f d4 f7       	paddq  xmm6,xmm15
    18ce:	66 0f 73 f6 20       	psllq  xmm6,0x20
    18d3:	66 41 0f d4 f6       	paddq  xmm6,xmm14
    18d8:	0f c6 ee dd          	shufps xmm5,xmm6,0xdd
    18dc:	66 0f 70 ed d8       	pshufd xmm5,xmm5,0xd8
    18e1:	66 0f 6f 74 24 e8    	movdqa xmm6,XMMWORD PTR [rsp-0x18]
    18e7:	66 0f fa c5          	psubd  xmm0,xmm5
    18eb:	66 0f 6f e9          	movdqa xmm5,xmm1
    18ef:	66 41 0f fe c0       	paddd  xmm0,xmm8
    18f4:	66 0f 72 e5 02       	psrad  xmm5,0x2
    18f9:	66 0f fa c5          	psubd  xmm0,xmm5
    18fd:	66 0f fe f8          	paddd  xmm7,xmm0
    1901:	66 0f 6f c6          	movdqa xmm0,xmm6
    1905:	66 0f f4 c1          	pmuludq xmm0,xmm1
    1909:	66 41 0f f4 ca       	pmuludq xmm1,xmm10
    190e:	66 0f d4 e0          	paddq  xmm4,xmm0
    1912:	66 0f 6f c6          	movdqa xmm0,xmm6
    1916:	66 0f f4 c2          	pmuludq xmm0,xmm2
    191a:	66 41 0f f4 d2       	pmuludq xmm2,xmm10
    191f:	66 0f 73 f4 20       	psllq  xmm4,0x20
    1924:	66 0f d4 cc          	paddq  xmm1,xmm4
    1928:	66 0f d4 d8          	paddq  xmm3,xmm0
    192c:	66 0f 73 f3 20       	psllq  xmm3,0x20
    1931:	66 0f d4 d3          	paddq  xmm2,xmm3
    1935:	0f c6 ca dd          	shufps xmm1,xmm2,0xdd
    1939:	66 0f 70 c9 d8       	pshufd xmm1,xmm1,0xd8
    193e:	66 0f 72 e1 01       	psrad  xmm1,0x1
    1943:	66 0f fa f9          	psubd  xmm7,xmm1
    1947:	66 41 0f 6f cc       	movdqa xmm1,xmm12
    194c:	66 0f 66 cf          	pcmpgtd xmm1,xmm7
    1950:	66 0f 6f c7          	movdqa xmm0,xmm7
    1954:	66 0f 62 c1          	punpckldq xmm0,xmm1
    1958:	66 0f 6a f9          	punpckhdq xmm7,xmm1
    195c:	66 41 0f d4 c1       	paddq  xmm0,xmm9
    1961:	66 0f d4 c7          	paddq  xmm0,xmm7
    1965:	66 44 0f 6f c8       	movdqa xmm9,xmm0
    196a:	3d a0 25 26 00       	cmp    eax,0x2625a0
    196f:	0f 85 9b fe ff ff    	jne    1810 <benchmark_larger_calls+0x50>
    1975:	66 0f 73 d8 08       	psrldq xmm0,0x8
    197a:	66 44 0f d4 c8       	paddq  xmm9,xmm0
    197f:	66 4c 0f 7e c8       	movq   rax,xmm9
    1984:	c3                   	ret

Disassembly of section .fini:

0000000000001988 <_fini>:
    1988:	f3 0f 1e fa          	endbr64
    198c:	48 83 ec 08          	sub    rsp,0x8
    1990:	48 83 c4 08          	add    rsp,0x8
    1994:	c3                   	ret
