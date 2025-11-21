
build/06_cse_O3:     file format elf64-x86-64


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
    1394:	66 0f 6f 35 f4 0c 00 	movdqa xmm6,XMMWORD PTR [rip+0xcf4]        # 2090 <_IO_stdin_used+0x90>
    139b:	00 
    139c:	66 45 0f ef c9       	pxor   xmm9,xmm9
    13a1:	66 0f ef c9          	pxor   xmm1,xmm1
    13a5:	31 c0                	xor    eax,eax
    13a7:	66 45 0f 6f d1       	movdqa xmm10,xmm9
    13ac:	66 44 0f 6f c1       	movdqa xmm8,xmm1
    13b1:	66 44 0f 6f 25 a6 0c 	movdqa xmm12,XMMWORD PTR [rip+0xca6]        # 2060 <_IO_stdin_used+0x60>
    13b8:	00 00 
    13ba:	66 44 0f 6f 35 ad 0c 	movdqa xmm14,XMMWORD PTR [rip+0xcad]        # 2070 <_IO_stdin_used+0x70>
    13c1:	00 00 
    13c3:	66 44 0f 6f 2d b4 0c 	movdqa xmm13,XMMWORD PTR [rip+0xcb4]        # 2080 <_IO_stdin_used+0x80>
    13ca:	00 00 
    13cc:	66 44 0f 66 d6       	pcmpgtd xmm10,xmm6
    13d1:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    13d8:	66 41 0f 6f dc       	movdqa xmm3,xmm12
    13dd:	66 45 0f 6f fa       	movdqa xmm15,xmm10
    13e2:	83 c0 01             	add    eax,0x1
    13e5:	66 44 0f 6f db       	movdqa xmm11,xmm3
    13ea:	66 0f 6f c3          	movdqa xmm0,xmm3
    13ee:	66 45 0f fe e6       	paddd  xmm12,xmm14
    13f3:	66 45 0f fe dd       	paddd  xmm11,xmm13
    13f8:	66 0f 72 f0 01       	pslld  xmm0,0x1
    13fd:	66 41 0f 6f e3       	movdqa xmm4,xmm11
    1402:	66 41 0f 6f d3       	movdqa xmm2,xmm11
    1407:	66 0f 72 f4 01       	pslld  xmm4,0x1
    140c:	66 0f fe d3          	paddd  xmm2,xmm3
    1410:	66 41 0f fe e3       	paddd  xmm4,xmm11
    1415:	66 0f fe e0          	paddd  xmm4,xmm0
    1419:	66 0f 6f ec          	movdqa xmm5,xmm4
    141d:	66 0f 72 f5 02       	pslld  xmm5,0x2
    1422:	66 0f fe e5          	paddd  xmm4,xmm5
    1426:	66 0f 6f c4          	movdqa xmm0,xmm4
    142a:	66 0f 6f e2          	movdqa xmm4,xmm2
    142e:	66 0f 72 f4 01       	pslld  xmm4,0x1
    1433:	66 0f 6f fc          	movdqa xmm7,xmm4
    1437:	66 0f fe ec          	paddd  xmm5,xmm4
    143b:	66 0f fe fa          	paddd  xmm7,xmm2
    143f:	66 0f fe c7          	paddd  xmm0,xmm7
    1443:	66 41 0f 6f f9       	movdqa xmm7,xmm9
    1448:	66 0f fe c5          	paddd  xmm0,xmm5
    144c:	66 0f 66 f8          	pcmpgtd xmm7,xmm0
    1450:	66 44 0f f4 f8       	pmuludq xmm15,xmm0
    1455:	66 0f 6f e8          	movdqa xmm5,xmm0
    1459:	66 0f f4 ee          	pmuludq xmm5,xmm6
    145d:	66 0f 6f e0          	movdqa xmm4,xmm0
    1461:	66 0f 72 e4 01       	psrad  xmm4,0x1
    1466:	66 0f f4 fe          	pmuludq xmm7,xmm6
    146a:	66 0f fe e0          	paddd  xmm4,xmm0
    146e:	66 0f 73 d0 20       	psrlq  xmm0,0x20
    1473:	66 41 0f d4 ff       	paddq  xmm7,xmm15
    1478:	66 45 0f 6f fa       	movdqa xmm15,xmm10
    147d:	66 0f 73 f7 20       	psllq  xmm7,0x20
    1482:	66 44 0f f4 f8       	pmuludq xmm15,xmm0
    1487:	66 0f d4 ef          	paddq  xmm5,xmm7
    148b:	66 41 0f 6f f9       	movdqa xmm7,xmm9
    1490:	66 0f 66 f8          	pcmpgtd xmm7,xmm0
    1494:	66 0f f4 c6          	pmuludq xmm0,xmm6
    1498:	66 0f f4 fe          	pmuludq xmm7,xmm6
    149c:	66 41 0f d4 ff       	paddq  xmm7,xmm15
    14a1:	66 45 0f 6f fa       	movdqa xmm15,xmm10
    14a6:	66 0f 73 f7 20       	psllq  xmm7,0x20
    14ab:	66 0f d4 c7          	paddq  xmm0,xmm7
    14af:	66 41 0f 6f fb       	movdqa xmm7,xmm11
    14b4:	0f c6 e8 dd          	shufps xmm5,xmm0,0xdd
    14b8:	66 41 0f 6f c3       	movdqa xmm0,xmm11
    14bd:	66 41 0f f4 fb       	pmuludq xmm7,xmm11
    14c2:	66 0f 70 ed d8       	pshufd xmm5,xmm5,0xd8
    14c7:	66 0f 73 d0 20       	psrlq  xmm0,0x20
    14cc:	66 0f fe e5          	paddd  xmm4,xmm5
    14d0:	66 45 0f 6f da       	movdqa xmm11,xmm10
    14d5:	66 0f 6f 2d c3 0b 00 	movdqa xmm5,XMMWORD PTR [rip+0xbc3]        # 20a0 <_IO_stdin_used+0xa0>
    14dc:	00 
    14dd:	66 0f f4 c0          	pmuludq xmm0,xmm0
    14e1:	66 0f fe eb          	paddd  xmm5,xmm3
    14e5:	66 0f fe d5          	paddd  xmm2,xmm5
    14e9:	66 0f 70 ff 08       	pshufd xmm7,xmm7,0x8
    14ee:	66 0f 70 c0 08       	pshufd xmm0,xmm0,0x8
    14f3:	66 0f 62 f8          	punpckldq xmm7,xmm0
    14f7:	66 0f 6f c3          	movdqa xmm0,xmm3
    14fb:	66 0f f4 c3          	pmuludq xmm0,xmm3
    14ff:	66 0f 73 d3 20       	psrlq  xmm3,0x20
    1504:	66 0f f4 db          	pmuludq xmm3,xmm3
    1508:	66 0f 70 c0 08       	pshufd xmm0,xmm0,0x8
    150d:	66 0f 70 db 08       	pshufd xmm3,xmm3,0x8
    1512:	66 0f 62 c3          	punpckldq xmm0,xmm3
    1516:	66 0f fe c7          	paddd  xmm0,xmm7
    151a:	66 41 0f 6f f9       	movdqa xmm7,xmm9
    151f:	66 0f 66 f8          	pcmpgtd xmm7,xmm0
    1523:	66 44 0f f4 d8       	pmuludq xmm11,xmm0
    1528:	66 0f 6f d8          	movdqa xmm3,xmm0
    152c:	66 0f f4 de          	pmuludq xmm3,xmm6
    1530:	66 0f f4 fe          	pmuludq xmm7,xmm6
    1534:	66 41 0f d4 fb       	paddq  xmm7,xmm11
    1539:	66 45 0f 6f d9       	movdqa xmm11,xmm9
    153e:	66 0f 73 f7 20       	psllq  xmm7,0x20
    1543:	66 0f d4 df          	paddq  xmm3,xmm7
    1547:	66 0f 6f f8          	movdqa xmm7,xmm0
    154b:	66 0f 73 d7 20       	psrlq  xmm7,0x20
    1550:	66 44 0f 66 df       	pcmpgtd xmm11,xmm7
    1555:	66 44 0f f4 ff       	pmuludq xmm15,xmm7
    155a:	66 0f f4 fe          	pmuludq xmm7,xmm6
    155e:	66 44 0f f4 de       	pmuludq xmm11,xmm6
    1563:	66 45 0f d4 df       	paddq  xmm11,xmm15
    1568:	66 41 0f 73 f3 20    	psllq  xmm11,0x20
    156e:	66 41 0f d4 fb       	paddq  xmm7,xmm11
    1573:	0f c6 df dd          	shufps xmm3,xmm7,0xdd
    1577:	66 0f 6f f8          	movdqa xmm7,xmm0
    157b:	66 0f 70 db d8       	pshufd xmm3,xmm3,0xd8
    1580:	66 0f fa c5          	psubd  xmm0,xmm5
    1584:	66 0f 72 f7 01       	pslld  xmm7,0x1
    1589:	66 41 0f 6f e9       	movdqa xmm5,xmm9
    158e:	66 0f fe df          	paddd  xmm3,xmm7
    1592:	66 0f 66 ec          	pcmpgtd xmm5,xmm4
    1596:	66 0f fe c3          	paddd  xmm0,xmm3
    159a:	66 0f 6f da          	movdqa xmm3,xmm2
    159e:	66 0f f4 da          	pmuludq xmm3,xmm2
    15a2:	66 0f 73 d2 20       	psrlq  xmm2,0x20
    15a7:	66 0f f4 d2          	pmuludq xmm2,xmm2
    15ab:	66 0f 70 db 08       	pshufd xmm3,xmm3,0x8
    15b0:	66 0f 70 d2 08       	pshufd xmm2,xmm2,0x8
    15b5:	66 0f 62 da          	punpckldq xmm3,xmm2
    15b9:	66 41 0f 6f d1       	movdqa xmm2,xmm9
    15be:	66 0f fe d8          	paddd  xmm3,xmm0
    15c2:	66 0f 6f c4          	movdqa xmm0,xmm4
    15c6:	66 0f 6a e5          	punpckhdq xmm4,xmm5
    15ca:	66 0f 66 d3          	pcmpgtd xmm2,xmm3
    15ce:	66 0f 62 c5          	punpckldq xmm0,xmm5
    15d2:	66 0f d4 e1          	paddq  xmm4,xmm1
    15d6:	66 41 0f d4 c0       	paddq  xmm0,xmm8
    15db:	66 44 0f 6f c3       	movdqa xmm8,xmm3
    15e0:	66 0f 6f cc          	movdqa xmm1,xmm4
    15e4:	66 44 0f 62 c2       	punpckldq xmm8,xmm2
    15e9:	66 0f 6a da          	punpckhdq xmm3,xmm2
    15ed:	66 44 0f d4 c0       	paddq  xmm8,xmm0
    15f2:	66 0f d4 cb          	paddq  xmm1,xmm3
    15f6:	3d 20 bc be 00       	cmp    eax,0xbebc20
    15fb:	0f 85 d7 fd ff ff    	jne    13d8 <benchmark_cse+0x48>
    1601:	66 41 0f d4 c8       	paddq  xmm1,xmm8
    1606:	66 0f 6f c1          	movdqa xmm0,xmm1
    160a:	66 0f 73 d8 08       	psrldq xmm0,0x8
    160f:	66 0f d4 c8          	paddq  xmm1,xmm0
    1613:	66 48 0f 7e c8       	movq   rax,xmm1
    1618:	c3                   	ret

Disassembly of section .fini:

000000000000161c <_fini>:
    161c:	f3 0f 1e fa          	endbr64
    1620:	48 83 ec 08          	sub    rsp,0x8
    1624:	48 83 c4 08          	add    rsp,0x8
    1628:	c3                   	ret
