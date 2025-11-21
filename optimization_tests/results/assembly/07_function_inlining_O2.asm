
build/07_function_inlining_O2:     file format elf64-x86-64


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
    10c4:	55                   	push   rbp
    10c5:	bf 01 00 00 00       	mov    edi,0x1
    10ca:	53                   	push   rbx
    10cb:	48 83 ec 58          	sub    rsp,0x58
    10cf:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    10d6:	00 00 
    10d8:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
    10dd:	31 c0                	xor    eax,eax
    10df:	48 8d 6c 24 20       	lea    rbp,[rsp+0x20]
    10e4:	e8 a7 02 00 00       	call   1390 <benchmark_inlining>
    10e9:	48 89 ee             	mov    rsi,rbp
    10ec:	48 89 c3             	mov    rbx,rax
    10ef:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    10f4:	e8 97 ff ff ff       	call   1090 <clock_gettime@plt>
    10f9:	48 89 5c 24 18       	mov    QWORD PTR [rsp+0x18],rbx
    10fe:	48 8d 5c 24 30       	lea    rbx,[rsp+0x30]
    1103:	bf 01 00 00 00       	mov    edi,0x1
    1108:	48 89 de             	mov    rsi,rbx
    110b:	e8 80 ff ff ff       	call   1090 <clock_gettime@plt>
    1110:	66 0f ef c0          	pxor   xmm0,xmm0
    1114:	66 0f ef c9          	pxor   xmm1,xmm1
    1118:	48 89 ee             	mov    rsi,rbp
    111b:	48 8b 44 24 38       	mov    rax,QWORD PTR [rsp+0x38]
    1120:	48 2b 44 24 28       	sub    rax,QWORD PTR [rsp+0x28]
    1125:	bf 01 00 00 00       	mov    edi,0x1
    112a:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    112f:	48 8b 44 24 30       	mov    rax,QWORD PTR [rsp+0x30]
    1134:	48 2b 44 24 20       	sub    rax,QWORD PTR [rsp+0x20]
    1139:	f2 0f 5e 05 57 0f 00 	divsd  xmm0,QWORD PTR [rip+0xf57]        # 2098 <_IO_stdin_used+0x98>
    1140:	00 
    1141:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    1146:	f2 0f 58 c1          	addsd  xmm0,xmm1
    114a:	f2 0f 11 04 24       	movsd  QWORD PTR [rsp],xmm0
    114f:	e8 3c ff ff ff       	call   1090 <clock_gettime@plt>
    1154:	31 c0                	xor    eax,eax
    1156:	e8 65 02 00 00       	call   13c0 <benchmark_larger_calls>
    115b:	48 89 de             	mov    rsi,rbx
    115e:	bf 01 00 00 00       	mov    edi,0x1
    1163:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    1168:	e8 23 ff ff ff       	call   1090 <clock_gettime@plt>
    116d:	48 8b 44 24 38       	mov    rax,QWORD PTR [rsp+0x38]
    1172:	66 0f ef c0          	pxor   xmm0,xmm0
    1176:	48 2b 44 24 28       	sub    rax,QWORD PTR [rsp+0x28]
    117b:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    1180:	66 0f ef c9          	pxor   xmm1,xmm1
    1184:	48 8b 44 24 30       	mov    rax,QWORD PTR [rsp+0x30]
    1189:	48 2b 44 24 20       	sub    rax,QWORD PTR [rsp+0x20]
    118e:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    1193:	f2 0f 5e 05 fd 0e 00 	divsd  xmm0,QWORD PTR [rip+0xefd]        # 2098 <_IO_stdin_used+0x98>
    119a:	00 
    119b:	66 0f 28 d0          	movapd xmm2,xmm0
    119f:	48 8d 3d 5e 0e 00 00 	lea    rdi,[rip+0xe5e]        # 2004 <_IO_stdin_used+0x4>
    11a6:	f2 0f 58 d1          	addsd  xmm2,xmm1
    11aa:	f2 0f 11 54 24 08    	movsd  QWORD PTR [rsp+0x8],xmm2
    11b0:	e8 cb fe ff ff       	call   1080 <puts@plt>
    11b5:	f2 0f 10 04 24       	movsd  xmm0,QWORD PTR [rsp]
    11ba:	ba 00 e1 f5 05       	mov    edx,0x5f5e100
    11bf:	48 8d 35 62 0e 00 00 	lea    rsi,[rip+0xe62]        # 2028 <_IO_stdin_used+0x28>
    11c6:	bf 02 00 00 00       	mov    edi,0x2
    11cb:	b8 01 00 00 00       	mov    eax,0x1
    11d0:	e8 db fe ff ff       	call   10b0 <__printf_chk@plt>
    11d5:	f2 0f 10 44 24 08    	movsd  xmm0,QWORD PTR [rsp+0x8]
    11db:	ba 80 96 98 00       	mov    edx,0x989680
    11e0:	48 8d 35 79 0e 00 00 	lea    rsi,[rip+0xe79]        # 2060 <_IO_stdin_used+0x60>
    11e7:	bf 02 00 00 00       	mov    edi,0x2
    11ec:	b8 01 00 00 00       	mov    eax,0x1
    11f1:	e8 ba fe ff ff       	call   10b0 <__printf_chk@plt>
    11f6:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
    11fb:	31 c0                	xor    eax,eax
    11fd:	48 8d 35 17 0e 00 00 	lea    rsi,[rip+0xe17]        # 201b <_IO_stdin_used+0x1b>
    1204:	bf 02 00 00 00       	mov    edi,0x2
    1209:	e8 a2 fe ff ff       	call   10b0 <__printf_chk@plt>
    120e:	48 8b 44 24 48       	mov    rax,QWORD PTR [rsp+0x48]
    1213:	64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
    121a:	00 00 
    121c:	75 09                	jne    1227 <main+0x167>
    121e:	48 83 c4 58          	add    rsp,0x58
    1222:	31 c0                	xor    eax,eax
    1224:	5b                   	pop    rbx
    1225:	5d                   	pop    rbp
    1226:	c3                   	ret
    1227:	e8 74 fe ff ff       	call   10a0 <__stack_chk_fail@plt>
    122c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000001230 <_start>:
    1230:	f3 0f 1e fa          	endbr64
    1234:	31 ed                	xor    ebp,ebp
    1236:	49 89 d1             	mov    r9,rdx
    1239:	5e                   	pop    rsi
    123a:	48 89 e2             	mov    rdx,rsp
    123d:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
    1241:	50                   	push   rax
    1242:	54                   	push   rsp
    1243:	45 31 c0             	xor    r8d,r8d
    1246:	31 c9                	xor    ecx,ecx
    1248:	48 8d 3d 71 fe ff ff 	lea    rdi,[rip+0xfffffffffffffe71]        # 10c0 <main>
    124f:	ff 15 83 2d 00 00    	call   QWORD PTR [rip+0x2d83]        # 3fd8 <__libc_start_main@GLIBC_2.34>
    1255:	f4                   	hlt
    1256:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    125d:	00 00 00 

0000000000001260 <deregister_tm_clones>:
    1260:	48 8d 3d a9 2d 00 00 	lea    rdi,[rip+0x2da9]        # 4010 <__TMC_END__>
    1267:	48 8d 05 a2 2d 00 00 	lea    rax,[rip+0x2da2]        # 4010 <__TMC_END__>
    126e:	48 39 f8             	cmp    rax,rdi
    1271:	74 15                	je     1288 <deregister_tm_clones+0x28>
    1273:	48 8b 05 66 2d 00 00 	mov    rax,QWORD PTR [rip+0x2d66]        # 3fe0 <_ITM_deregisterTMCloneTable@Base>
    127a:	48 85 c0             	test   rax,rax
    127d:	74 09                	je     1288 <deregister_tm_clones+0x28>
    127f:	ff e0                	jmp    rax
    1281:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    1288:	c3                   	ret
    1289:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001290 <register_tm_clones>:
    1290:	48 8d 3d 79 2d 00 00 	lea    rdi,[rip+0x2d79]        # 4010 <__TMC_END__>
    1297:	48 8d 35 72 2d 00 00 	lea    rsi,[rip+0x2d72]        # 4010 <__TMC_END__>
    129e:	48 29 fe             	sub    rsi,rdi
    12a1:	48 89 f0             	mov    rax,rsi
    12a4:	48 c1 ee 3f          	shr    rsi,0x3f
    12a8:	48 c1 f8 03          	sar    rax,0x3
    12ac:	48 01 c6             	add    rsi,rax
    12af:	48 d1 fe             	sar    rsi,1
    12b2:	74 14                	je     12c8 <register_tm_clones+0x38>
    12b4:	48 8b 05 35 2d 00 00 	mov    rax,QWORD PTR [rip+0x2d35]        # 3ff0 <_ITM_registerTMCloneTable@Base>
    12bb:	48 85 c0             	test   rax,rax
    12be:	74 08                	je     12c8 <register_tm_clones+0x38>
    12c0:	ff e0                	jmp    rax
    12c2:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    12c8:	c3                   	ret
    12c9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000012d0 <__do_global_dtors_aux>:
    12d0:	f3 0f 1e fa          	endbr64
    12d4:	80 3d 35 2d 00 00 00 	cmp    BYTE PTR [rip+0x2d35],0x0        # 4010 <__TMC_END__>
    12db:	75 2b                	jne    1308 <__do_global_dtors_aux+0x38>
    12dd:	55                   	push   rbp
    12de:	48 83 3d 12 2d 00 00 	cmp    QWORD PTR [rip+0x2d12],0x0        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    12e5:	00 
    12e6:	48 89 e5             	mov    rbp,rsp
    12e9:	74 0c                	je     12f7 <__do_global_dtors_aux+0x27>
    12eb:	48 8b 3d 16 2d 00 00 	mov    rdi,QWORD PTR [rip+0x2d16]        # 4008 <__dso_handle>
    12f2:	e8 79 fd ff ff       	call   1070 <__cxa_finalize@plt>
    12f7:	e8 64 ff ff ff       	call   1260 <deregister_tm_clones>
    12fc:	c6 05 0d 2d 00 00 01 	mov    BYTE PTR [rip+0x2d0d],0x1        # 4010 <__TMC_END__>
    1303:	5d                   	pop    rbp
    1304:	c3                   	ret
    1305:	0f 1f 00             	nop    DWORD PTR [rax]
    1308:	c3                   	ret
    1309:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001310 <frame_dummy>:
    1310:	f3 0f 1e fa          	endbr64
    1314:	e9 77 ff ff ff       	jmp    1290 <register_tm_clones>
    1319:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001320 <compute_with_calls>:
    1320:	f3 0f 1e fa          	endbr64
    1324:	89 f8                	mov    eax,edi
    1326:	0f af c7             	imul   eax,edi
    1329:	8d 44 b8 0a          	lea    eax,[rax+rdi*4+0xa]
    132d:	c3                   	ret
    132e:	66 90                	xchg   ax,ax

0000000000001330 <larger_function>:
    1330:	f3 0f 1e fa          	endbr64
    1334:	45 31 c9             	xor    r9d,r9d
    1337:	31 c9                	xor    ecx,ecx
    1339:	45 31 c0             	xor    r8d,r8d
    133c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    1340:	89 f0                	mov    eax,esi
    1342:	83 c1 01             	add    ecx,0x1
    1345:	45 01 c8             	add    r8d,r9d
    1348:	41 01 f9             	add    r9d,edi
    134b:	99                   	cdq
    134c:	f7 f9                	idiv   ecx
    134e:	41 29 c0             	sub    r8d,eax
    1351:	83 f9 05             	cmp    ecx,0x5
    1354:	75 ea                	jne    1340 <larger_function+0x10>
    1356:	44 89 c0             	mov    eax,r8d
    1359:	c3                   	ret
    135a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

0000000000001360 <compute_with_larger_call>:
    1360:	f3 0f 1e fa          	endbr64
    1364:	44 8d 4f 01          	lea    r9d,[rdi+0x1]
    1368:	45 31 c0             	xor    r8d,r8d
    136b:	31 f6                	xor    esi,esi
    136d:	31 c9                	xor    ecx,ecx
    136f:	90                   	nop
    1370:	44 89 c8             	mov    eax,r9d
    1373:	83 c1 01             	add    ecx,0x1
    1376:	44 01 c6             	add    esi,r8d
    1379:	41 01 f8             	add    r8d,edi
    137c:	99                   	cdq
    137d:	f7 f9                	idiv   ecx
    137f:	29 c6                	sub    esi,eax
    1381:	83 f9 05             	cmp    ecx,0x5
    1384:	75 ea                	jne    1370 <compute_with_larger_call+0x10>
    1386:	89 f0                	mov    eax,esi
    1388:	c3                   	ret
    1389:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001390 <benchmark_inlining>:
    1390:	f3 0f 1e fa          	endbr64
    1394:	31 c9                	xor    ecx,ecx
    1396:	31 c0                	xor    eax,eax
    1398:	31 f6                	xor    esi,esi
    139a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    13a0:	89 c2                	mov    edx,eax
    13a2:	0f af d0             	imul   edx,eax
    13a5:	83 c0 01             	add    eax,0x1
    13a8:	8d 54 4a 0a          	lea    edx,[rdx+rcx*2+0xa]
    13ac:	83 c1 02             	add    ecx,0x2
    13af:	48 63 d2             	movsxd rdx,edx
    13b2:	48 01 d6             	add    rsi,rdx
    13b5:	3d 00 e1 f5 05       	cmp    eax,0x5f5e100
    13ba:	75 e4                	jne    13a0 <benchmark_inlining+0x10>
    13bc:	48 89 f0             	mov    rax,rsi
    13bf:	c3                   	ret

00000000000013c0 <benchmark_larger_calls>:
    13c0:	f3 0f 1e fa          	endbr64
    13c4:	45 31 c0             	xor    r8d,r8d
    13c7:	45 31 d2             	xor    r10d,r10d
    13ca:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    13d0:	45 89 c1             	mov    r9d,r8d
    13d3:	31 ff                	xor    edi,edi
    13d5:	41 83 c0 01          	add    r8d,0x1
    13d9:	31 d2                	xor    edx,edx
    13db:	31 c9                	xor    ecx,ecx
    13dd:	0f 1f 00             	nop    DWORD PTR [rax]
    13e0:	44 89 c0             	mov    eax,r8d
    13e3:	8d 34 17             	lea    esi,[rdi+rdx*1]
    13e6:	83 c1 01             	add    ecx,0x1
    13e9:	44 01 cf             	add    edi,r9d
    13ec:	99                   	cdq
    13ed:	f7 f9                	idiv   ecx
    13ef:	29 c6                	sub    esi,eax
    13f1:	48 63 d6             	movsxd rdx,esi
    13f4:	83 f9 05             	cmp    ecx,0x5
    13f7:	75 e7                	jne    13e0 <benchmark_larger_calls+0x20>
    13f9:	49 01 d2             	add    r10,rdx
    13fc:	41 81 f8 80 96 98 00 	cmp    r8d,0x989680
    1403:	75 cb                	jne    13d0 <benchmark_larger_calls+0x10>
    1405:	4c 89 d0             	mov    rax,r10
    1408:	c3                   	ret

Disassembly of section .fini:

000000000000140c <_fini>:
    140c:	f3 0f 1e fa          	endbr64
    1410:	48 83 ec 08          	sub    rsp,0x8
    1414:	48 83 c4 08          	add    rsp,0x8
    1418:	c3                   	ret
