
build/06_cse_O2:     file format elf64-x86-64


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
    10e3:	e8 a8 02 00 00       	call   1390 <benchmark_cse>
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
    112f:	f2 0f 5e 05 79 0f 00 	divsd  xmm0,QWORD PTR [rip+0xf79]        # 20b0 <_IO_stdin_used+0xb0>
    1136:	00 
    1137:	48 8d 3d ca 0e 00 00 	lea    rdi,[rip+0xeca]        # 2008 <_IO_stdin_used+0x8>
    113e:	f2 0f 58 c1          	addsd  xmm0,xmm1
    1142:	f2 0f 11 44 24 08    	movsd  QWORD PTR [rsp+0x8],xmm0
    1148:	e8 33 ff ff ff       	call   1080 <puts@plt>
    114d:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
    1152:	48 8d 35 d5 0e 00 00 	lea    rsi,[rip+0xed5]        # 202e <_IO_stdin_used+0x2e>
    1159:	31 c0                	xor    eax,eax
    115b:	bf 02 00 00 00       	mov    edi,0x2
    1160:	e8 4b ff ff ff       	call   10b0 <__printf_chk@plt>
    1165:	f2 0f 10 44 24 08    	movsd  xmm0,QWORD PTR [rsp+0x8]
    116b:	bf 02 00 00 00       	mov    edi,0x2
    1170:	48 8d 35 c4 0e 00 00 	lea    rsi,[rip+0xec4]        # 203b <_IO_stdin_used+0x3b>
    1177:	b8 01 00 00 00       	mov    eax,0x1
    117c:	e8 2f ff ff ff       	call   10b0 <__printf_chk@plt>
    1181:	31 c0                	xor    eax,eax
    1183:	ba 80 f0 fa 02       	mov    edx,0x2faf080
    1188:	48 8d 35 c0 0e 00 00 	lea    rsi,[rip+0xec0]        # 204f <_IO_stdin_used+0x4f>
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

00000000000012b0 <compute_with_redundancy>:
    12b0:	f3 0f 1e fa          	endbr64
    12b4:	8d 04 37             	lea    eax,[rdi+rsi*1]
    12b7:	8d 14 00             	lea    edx,[rax+rax*1]
    12ba:	8d 0c 02             	lea    ecx,[rdx+rax*1]
    12bd:	8d 04 76             	lea    eax,[rsi+rsi*2]
    12c0:	8d 34 78             	lea    esi,[rax+rdi*2]
    12c3:	8d 04 b5 00 00 00 00 	lea    eax,[rsi*4+0x0]
    12ca:	01 c2                	add    edx,eax
    12cc:	01 f0                	add    eax,esi
    12ce:	01 c8                	add    eax,ecx
    12d0:	01 c2                	add    edx,eax
    12d2:	89 d0                	mov    eax,edx
    12d4:	48 63 ca             	movsxd rcx,edx
    12d7:	48 69 c9 56 55 55 55 	imul   rcx,rcx,0x55555556
    12de:	c1 e8 1f             	shr    eax,0x1f
    12e1:	01 d0                	add    eax,edx
    12e3:	d1 f8                	sar    eax,1
    12e5:	01 d0                	add    eax,edx
    12e7:	48 c1 e9 20          	shr    rcx,0x20
    12eb:	c1 fa 1f             	sar    edx,0x1f
    12ee:	29 d1                	sub    ecx,edx
    12f0:	01 c8                	add    eax,ecx
    12f2:	c3                   	ret
    12f3:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    12fa:	00 00 00 00 
    12fe:	66 90                	xchg   ax,ax

0000000000001300 <compute_optimized>:
    1300:	f3 0f 1e fa          	endbr64
    1304:	8d 04 37             	lea    eax,[rdi+rsi*1]
    1307:	8d 14 76             	lea    edx,[rsi+rsi*2]
    130a:	8d 34 7a             	lea    esi,[rdx+rdi*2]
    130d:	8d 14 00             	lea    edx,[rax+rax*1]
    1310:	8d 0c 02             	lea    ecx,[rdx+rax*1]
    1313:	8d 04 b5 00 00 00 00 	lea    eax,[rsi*4+0x0]
    131a:	01 c2                	add    edx,eax
    131c:	01 f0                	add    eax,esi
    131e:	01 c8                	add    eax,ecx
    1320:	01 c2                	add    edx,eax
    1322:	89 d0                	mov    eax,edx
    1324:	48 63 ca             	movsxd rcx,edx
    1327:	48 69 c9 56 55 55 55 	imul   rcx,rcx,0x55555556
    132e:	c1 e8 1f             	shr    eax,0x1f
    1331:	01 d0                	add    eax,edx
    1333:	d1 f8                	sar    eax,1
    1335:	01 d0                	add    eax,edx
    1337:	48 c1 e9 20          	shr    rcx,0x20
    133b:	c1 fa 1f             	sar    edx,0x1f
    133e:	29 d1                	sub    ecx,edx
    1340:	01 c8                	add    eax,ecx
    1342:	c3                   	ret
    1343:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    134a:	00 00 00 00 
    134e:	66 90                	xchg   ax,ax

0000000000001350 <complex_computation>:
    1350:	f3 0f 1e fa          	endbr64
    1354:	89 f8                	mov    eax,edi
    1356:	89 f9                	mov    ecx,edi
    1358:	41 b8 ab aa aa aa    	mov    r8d,0xaaaaaaab
    135e:	0f af c7             	imul   eax,edi
    1361:	89 f7                	mov    edi,esi
    1363:	01 f1                	add    ecx,esi
    1365:	0f af fe             	imul   edi,esi
    1368:	01 c7                	add    edi,eax
    136a:	48 89 f8             	mov    rax,rdi
    136d:	49 0f af f8          	imul   rdi,r8
    1371:	48 c1 ef 21          	shr    rdi,0x21
    1375:	8d 3c 47             	lea    edi,[rdi+rax*2]
    1378:	29 d0                	sub    eax,edx
    137a:	01 c7                	add    edi,eax
    137c:	8d 04 11             	lea    eax,[rcx+rdx*1]
    137f:	0f af c0             	imul   eax,eax
    1382:	01 f8                	add    eax,edi
    1384:	c3                   	ret
    1385:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    138c:	00 00 00 00 

0000000000001390 <benchmark_cse>:
    1390:	f3 0f 1e fa          	endbr64
    1394:	66 0f 6f 25 f4 0c 00 	movdqa xmm4,XMMWORD PTR [rip+0xcf4]        # 2090 <_IO_stdin_used+0x90>
    139b:	00 
    139c:	66 45 0f ef c9       	pxor   xmm9,xmm9
    13a1:	66 0f ef db          	pxor   xmm3,xmm3
    13a5:	31 c0                	xor    eax,eax
    13a7:	66 45 0f 6f d9       	movdqa xmm11,xmm9
    13ac:	66 44 0f 6f c3       	movdqa xmm8,xmm3
    13b1:	66 44 0f 6f 25 a6 0c 	movdqa xmm12,XMMWORD PTR [rip+0xca6]        # 2060 <_IO_stdin_used+0x60>
    13b8:	00 00 
    13ba:	66 44 0f 6f 3d ad 0c 	movdqa xmm15,XMMWORD PTR [rip+0xcad]        # 2070 <_IO_stdin_used+0x70>
    13c1:	00 00 
    13c3:	66 44 0f 66 dc       	pcmpgtd xmm11,xmm4
    13c8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    13cf:	00 
    13d0:	66 0f 6f 2d a8 0c 00 	movdqa xmm5,XMMWORD PTR [rip+0xca8]        # 2080 <_IO_stdin_used+0x80>
    13d7:	00 
    13d8:	66 41 0f 6f f4       	movdqa xmm6,xmm12
    13dd:	66 45 0f 6f eb       	movdqa xmm13,xmm11
    13e2:	83 c0 01             	add    eax,0x1
    13e5:	66 0f 6f ce          	movdqa xmm1,xmm6
    13e9:	66 45 0f 6f f3       	movdqa xmm14,xmm11
    13ee:	66 45 0f fe e7       	paddd  xmm12,xmm15
    13f3:	66 0f fe ee          	paddd  xmm5,xmm6
    13f7:	66 0f 72 f1 01       	pslld  xmm1,0x1
    13fc:	66 0f 6f c5          	movdqa xmm0,xmm5
    1400:	66 0f 6f d5          	movdqa xmm2,xmm5
    1404:	66 0f 72 f0 01       	pslld  xmm0,0x1
    1409:	66 0f fe d6          	paddd  xmm2,xmm6
    140d:	66 0f fe c5          	paddd  xmm0,xmm5
    1411:	66 0f 6f fa          	movdqa xmm7,xmm2
    1415:	66 0f fe c1          	paddd  xmm0,xmm1
    1419:	66 0f 72 f7 01       	pslld  xmm7,0x1
    141e:	66 0f 6f c8          	movdqa xmm1,xmm0
    1422:	66 44 0f 6f d7       	movdqa xmm10,xmm7
    1427:	66 0f 72 f1 02       	pslld  xmm1,0x2
    142c:	66 44 0f fe d2       	paddd  xmm10,xmm2
    1431:	66 0f fe c1          	paddd  xmm0,xmm1
    1435:	66 0f fe cf          	paddd  xmm1,xmm7
    1439:	66 41 0f fe c2       	paddd  xmm0,xmm10
    143e:	66 0f fe c1          	paddd  xmm0,xmm1
    1442:	66 0f 6f c8          	movdqa xmm1,xmm0
    1446:	66 44 0f f4 e8       	pmuludq xmm13,xmm0
    144b:	66 0f 6f f8          	movdqa xmm7,xmm0
    144f:	66 0f 72 e1 01       	psrad  xmm1,0x1
    1454:	66 0f f4 fc          	pmuludq xmm7,xmm4
    1458:	66 0f fe c8          	paddd  xmm1,xmm0
    145c:	66 44 0f 6f d1       	movdqa xmm10,xmm1
    1461:	66 41 0f 6f c9       	movdqa xmm1,xmm9
    1466:	66 0f 66 c8          	pcmpgtd xmm1,xmm0
    146a:	66 0f 73 d0 20       	psrlq  xmm0,0x20
    146f:	66 0f f4 cc          	pmuludq xmm1,xmm4
    1473:	66 41 0f d4 cd       	paddq  xmm1,xmm13
    1478:	66 45 0f 6f eb       	movdqa xmm13,xmm11
    147d:	66 0f 73 f1 20       	psllq  xmm1,0x20
    1482:	66 44 0f f4 e8       	pmuludq xmm13,xmm0
    1487:	66 0f d4 f9          	paddq  xmm7,xmm1
    148b:	66 41 0f 6f c9       	movdqa xmm1,xmm9
    1490:	66 0f 66 c8          	pcmpgtd xmm1,xmm0
    1494:	66 0f f4 c4          	pmuludq xmm0,xmm4
    1498:	66 0f f4 cc          	pmuludq xmm1,xmm4
    149c:	66 41 0f d4 cd       	paddq  xmm1,xmm13
    14a1:	66 45 0f 6f eb       	movdqa xmm13,xmm11
    14a6:	66 0f 73 f1 20       	psllq  xmm1,0x20
    14ab:	66 0f d4 c8          	paddq  xmm1,xmm0
    14af:	66 0f 6f c6          	movdqa xmm0,xmm6
    14b3:	0f c6 f9 dd          	shufps xmm7,xmm1,0xdd
    14b7:	66 0f 73 d0 20       	psrlq  xmm0,0x20
    14bc:	66 41 0f 6f ca       	movdqa xmm1,xmm10
    14c1:	66 44 0f 6f d6       	movdqa xmm10,xmm6
    14c6:	66 44 0f f4 d6       	pmuludq xmm10,xmm6
    14cb:	66 0f f4 c0          	pmuludq xmm0,xmm0
    14cf:	66 0f 70 ff d8       	pshufd xmm7,xmm7,0xd8
    14d4:	66 0f fe cf          	paddd  xmm1,xmm7
    14d8:	66 0f 6f 3d c0 0b 00 	movdqa xmm7,XMMWORD PTR [rip+0xbc0]        # 20a0 <_IO_stdin_used+0xa0>
    14df:	00 
    14e0:	66 0f fe fe          	paddd  xmm7,xmm6
    14e4:	66 0f fe d7          	paddd  xmm2,xmm7
    14e8:	66 41 0f 70 f2 08    	pshufd xmm6,xmm10,0x8
    14ee:	66 0f 70 c0 08       	pshufd xmm0,xmm0,0x8
    14f3:	66 45 0f 6f d1       	movdqa xmm10,xmm9
    14f8:	66 0f 62 f0          	punpckldq xmm6,xmm0
    14fc:	66 0f 6f c5          	movdqa xmm0,xmm5
    1500:	66 0f f4 c5          	pmuludq xmm0,xmm5
    1504:	66 0f 73 d5 20       	psrlq  xmm5,0x20
    1509:	66 0f f4 ed          	pmuludq xmm5,xmm5
    150d:	66 0f 70 c0 08       	pshufd xmm0,xmm0,0x8
    1512:	66 0f 70 ed 08       	pshufd xmm5,xmm5,0x8
    1517:	66 0f 62 c5          	punpckldq xmm0,xmm5
    151b:	66 0f fe f0          	paddd  xmm6,xmm0
    151f:	66 44 0f 66 d6       	pcmpgtd xmm10,xmm6
    1524:	66 44 0f f4 ee       	pmuludq xmm13,xmm6
    1529:	66 0f 6f ee          	movdqa xmm5,xmm6
    152d:	66 0f 6f c6          	movdqa xmm0,xmm6
    1531:	66 0f f4 f4          	pmuludq xmm6,xmm4
    1535:	66 0f 72 f0 01       	pslld  xmm0,0x1
    153a:	66 44 0f f4 d4       	pmuludq xmm10,xmm4
    153f:	66 45 0f d4 d5       	paddq  xmm10,xmm13
    1544:	66 45 0f 6f e9       	movdqa xmm13,xmm9
    1549:	66 41 0f 73 f2 20    	psllq  xmm10,0x20
    154f:	66 41 0f d4 f2       	paddq  xmm6,xmm10
    1554:	66 44 0f 6f d5       	movdqa xmm10,xmm5
    1559:	66 0f fa ef          	psubd  xmm5,xmm7
    155d:	66 41 0f 73 d2 20    	psrlq  xmm10,0x20
    1563:	66 45 0f 66 ea       	pcmpgtd xmm13,xmm10
    1568:	66 45 0f f4 f2       	pmuludq xmm14,xmm10
    156d:	66 44 0f f4 d4       	pmuludq xmm10,xmm4
    1572:	66 44 0f f4 ec       	pmuludq xmm13,xmm4
    1577:	66 45 0f d4 ee       	paddq  xmm13,xmm14
    157c:	66 41 0f 73 f5 20    	psllq  xmm13,0x20
    1582:	66 45 0f d4 d5       	paddq  xmm10,xmm13
    1587:	41 0f c6 f2 dd       	shufps xmm6,xmm10,0xdd
    158c:	66 0f 70 f6 d8       	pshufd xmm6,xmm6,0xd8
    1591:	66 0f fe c6          	paddd  xmm0,xmm6
    1595:	66 41 0f 6f f1       	movdqa xmm6,xmm9
    159a:	66 0f fe c5          	paddd  xmm0,xmm5
    159e:	66 0f 66 f1          	pcmpgtd xmm6,xmm1
    15a2:	66 0f 6f ea          	movdqa xmm5,xmm2
    15a6:	66 0f f4 ea          	pmuludq xmm5,xmm2
    15aa:	66 0f 73 d2 20       	psrlq  xmm2,0x20
    15af:	66 0f f4 d2          	pmuludq xmm2,xmm2
    15b3:	66 0f 70 ed 08       	pshufd xmm5,xmm5,0x8
    15b8:	66 0f 70 d2 08       	pshufd xmm2,xmm2,0x8
    15bd:	66 0f 62 ea          	punpckldq xmm5,xmm2
    15c1:	66 0f 6f d1          	movdqa xmm2,xmm1
    15c5:	66 0f 6a ce          	punpckhdq xmm1,xmm6
    15c9:	66 0f fe c5          	paddd  xmm0,xmm5
    15cd:	66 41 0f 6f e9       	movdqa xmm5,xmm9
    15d2:	66 0f 62 d6          	punpckldq xmm2,xmm6
    15d6:	66 0f 66 e8          	pcmpgtd xmm5,xmm0
    15da:	66 41 0f d4 d0       	paddq  xmm2,xmm8
    15df:	66 0f d4 cb          	paddq  xmm1,xmm3
    15e3:	66 44 0f 6f c0       	movdqa xmm8,xmm0
    15e8:	66 0f 6f d9          	movdqa xmm3,xmm1
    15ec:	66 44 0f 62 c5       	punpckldq xmm8,xmm5
    15f1:	66 0f 6a c5          	punpckhdq xmm0,xmm5
    15f5:	66 44 0f d4 c2       	paddq  xmm8,xmm2
    15fa:	66 0f d4 d8          	paddq  xmm3,xmm0
    15fe:	3d 20 bc be 00       	cmp    eax,0xbebc20
    1603:	0f 85 c7 fd ff ff    	jne    13d0 <benchmark_cse+0x40>
    1609:	66 44 0f d4 c3       	paddq  xmm8,xmm3
    160e:	66 41 0f 6f c0       	movdqa xmm0,xmm8
    1613:	66 0f 73 d8 08       	psrldq xmm0,0x8
    1618:	66 44 0f d4 c0       	paddq  xmm8,xmm0
    161d:	66 4c 0f 7e c0       	movq   rax,xmm8
    1622:	c3                   	ret

Disassembly of section .fini:

0000000000001624 <_fini>:
    1624:	f3 0f 1e fa          	endbr64
    1628:	48 83 ec 08          	sub    rsp,0x8
    162c:	48 83 c4 08          	add    rsp,0x8
    1630:	c3                   	ret
