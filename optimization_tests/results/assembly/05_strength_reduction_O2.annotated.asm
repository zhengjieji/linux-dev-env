
build/05_strength_reduction_O2:     file format elf64-x86-64


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
    10c5:	48 83 ec 50          	sub    rsp,0x50
    10c9:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    10d0:	00 00 
    10d2:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
    10d7:	31 c0                	xor    eax,eax
    10d9:	e8 52 02 00 00       	call   1330 <benchmark_strength_reduction>
    10de:	48 8d 74 24 20       	lea    rsi,[rsp+0x20]
    10e3:	bf 01 00 00 00       	mov    edi,0x1
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
    112f:	f2 0f 5e 05 19 0f 00 	divsd  xmm0,QWORD PTR [rip+0xf19]        # 2050 <_IO_stdin_used+0x50>
    1136:	00 
    1137:	48 8d 3d c6 0e 00 00 	lea    rdi,[rip+0xec6]        # 2004 <_IO_stdin_used+0x4>
    113e:	f2 0f 58 c1          	addsd  xmm0,xmm1
    1142:	f2 0f 11 44 24 08    	movsd  QWORD PTR [rsp+0x8],xmm0
    1148:	e8 33 ff ff ff       	call   1080 <puts@plt>
    114d:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
    1152:	48 8d 35 c3 0e 00 00 	lea    rsi,[rip+0xec3]        # 201c <_IO_stdin_used+0x1c>
    1159:	31 c0                	xor    eax,eax
    115b:	bf 02 00 00 00       	mov    edi,0x2
    1160:	e8 4b ff ff ff       	call   10b0 <__printf_chk@plt>
    1165:	f2 0f 10 44 24 08    	movsd  xmm0,QWORD PTR [rsp+0x8]
    116b:	bf 02 00 00 00       	mov    edi,0x2
    1170:	48 8d 35 b2 0e 00 00 	lea    rsi,[rip+0xeb2]        # 2029 <_IO_stdin_used+0x29>
    1177:	b8 01 00 00 00       	mov    eax,0x1
    117c:	e8 2f ff ff ff       	call   10b0 <__printf_chk@plt>
    1181:	31 c0                	xor    eax,eax
    1183:	ba 00 e1 f5 05       	mov    edx,0x5f5e100
    1188:	48 8d 35 ae 0e 00 00 	lea    rsi,[rip+0xeae]        # 203d <_IO_stdin_used+0x3d>
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

00000000000012b0 <compute_with_expensive_ops>:
    12b0:	f3 0f 1e fa          	endbr64
    12b4:	8d 14 bd 00 00 00 00 	lea    edx,[rdi*4+0x0]
    12bb:	89 f8                	mov    eax,edi
    12bd:	8d 14 7a             	lea    edx,[rdx+rdi*2]
    12c0:	8d 0c fa             	lea    ecx,[rdx+rdi*8]
    12c3:	89 fa                	mov    edx,edi
    12c5:	c1 e2 04             	shl    edx,0x4
    12c8:	01 ca                	add    edx,ecx
    12ca:	89 f9                	mov    ecx,edi
    12cc:	c1 e9 1f             	shr    ecx,0x1f
    12cf:	01 f9                	add    ecx,edi
    12d1:	d1 f9                	sar    ecx,1
    12d3:	01 d1                	add    ecx,edx
    12d5:	85 ff                	test   edi,edi
    12d7:	8d 57 03             	lea    edx,[rdi+0x3]
    12da:	0f 49 d7             	cmovns edx,edi
    12dd:	c1 fa 02             	sar    edx,0x2
    12e0:	01 ca                	add    edx,ecx
    12e2:	89 f9                	mov    ecx,edi
    12e4:	c1 f9 1f             	sar    ecx,0x1f
    12e7:	c1 e9 1d             	shr    ecx,0x1d
    12ea:	01 c8                	add    eax,ecx
    12ec:	83 e0 07             	and    eax,0x7
    12ef:	29 c8                	sub    eax,ecx
    12f1:	8d 84 02 87 00 00 00 	lea    eax,[rdx+rax*1+0x87]
    12f8:	c3                   	ret
    12f9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001300 <compute_optimized>:
    1300:	f3 0f 1e fa          	endbr64
    1304:	8d 04 fd 00 00 00 00 	lea    eax,[rdi*8+0x0]
    130b:	8d 14 7f             	lea    edx,[rdi+rdi*2]
    130e:	8d 14 50             	lea    edx,[rax+rdx*2]
    1311:	89 f8                	mov    eax,edi
    1313:	c1 e0 04             	shl    eax,0x4
    1316:	01 d0                	add    eax,edx
    1318:	89 fa                	mov    edx,edi
    131a:	d1 fa                	sar    edx,1
    131c:	01 c2                	add    edx,eax
    131e:	89 f8                	mov    eax,edi
    1320:	83 e7 07             	and    edi,0x7
    1323:	c1 f8 02             	sar    eax,0x2
    1326:	01 d0                	add    eax,edx
    1328:	8d 84 38 87 00 00 00 	lea    eax,[rax+rdi*1+0x87]
    132f:	c3                   	ret

0000000000001330 <benchmark_strength_reduction>:
    1330:	f3 0f 1e fa          	endbr64
    1334:	31 f6                	xor    esi,esi
    1336:	45 31 c0             	xor    r8d,r8d
    1339:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    1340:	89 f7                	mov    edi,esi
    1342:	83 c6 01             	add    esi,0x1
    1345:	e8 66 ff ff ff       	call   12b0 <compute_with_expensive_ops>
    134a:	48 98                	cdqe
    134c:	49 01 c0             	add    r8,rax
    134f:	81 fe 00 e1 f5 05    	cmp    esi,0x5f5e100
    1355:	75 e9                	jne    1340 <benchmark_strength_reduction+0x10>
    1357:	4c 89 c0             	mov    rax,r8
    135a:	c3                   	ret

Disassembly of section .fini:

000000000000135c <_fini>:
    135c:	f3 0f 1e fa          	endbr64
    1360:	48 83 ec 08          	sub    rsp,0x8
    1364:	48 83 c4 08          	add    rsp,0x8
    1368:	c3                   	ret
