
build/05_strength_reduction_O0:     file format elf64-x86-64


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

00000000000010b0 <printf@plt>:
    10b0:	f3 0f 1e fa          	endbr64
    10b4:	ff 25 16 2f 00 00    	jmp    QWORD PTR [rip+0x2f16]        # 3fd0 <printf@GLIBC_2.2.5>
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
    10d8:	48 8d 3d 2c 02 00 00 	lea    rdi,[rip+0x22c]        # 130b <main>
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

00000000000011a9 <compute_with_expensive_ops>:
    11a9:	f3 0f 1e fa          	endbr64
    11ad:	55                   	push   rbp
    11ae:	48 89 e5             	mov    rbp,rsp
    11b1:	89 7d ec             	mov    DWORD PTR [rbp-0x14],edi
    11b4:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
    11bb:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    11be:	01 c0                	add    eax,eax
    11c0:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    11c3:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    11c6:	c1 e0 02             	shl    eax,0x2
    11c9:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    11cc:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    11cf:	c1 e0 03             	shl    eax,0x3
    11d2:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    11d5:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    11d8:	c1 e0 04             	shl    eax,0x4
    11db:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    11de:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    11e1:	89 c2                	mov    edx,eax
    11e3:	c1 ea 1f             	shr    edx,0x1f
    11e6:	01 d0                	add    eax,edx
    11e8:	d1 f8                	sar    eax,1
    11ea:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    11ed:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    11f0:	8d 50 03             	lea    edx,[rax+0x3]
    11f3:	85 c0                	test   eax,eax
    11f5:	0f 48 c2             	cmovs  eax,edx
    11f8:	c1 f8 02             	sar    eax,0x2
    11fb:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    11fe:	8b 55 ec             	mov    edx,DWORD PTR [rbp-0x14]
    1201:	89 d0                	mov    eax,edx
    1203:	c1 f8 1f             	sar    eax,0x1f
    1206:	c1 e8 1d             	shr    eax,0x1d
    1209:	01 c2                	add    edx,eax
    120b:	83 e2 07             	and    edx,0x7
    120e:	29 c2                	sub    edx,eax
    1210:	89 d0                	mov    eax,edx
    1212:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    1215:	c7 45 f4 00 00 00 00 	mov    DWORD PTR [rbp-0xc],0x0
    121c:	c7 45 f8 00 00 00 00 	mov    DWORD PTR [rbp-0x8],0x0
    1223:	eb 10                	jmp    1235 <compute_with_expensive_ops+0x8c>
    1225:	8b 55 f8             	mov    edx,DWORD PTR [rbp-0x8]
    1228:	89 d0                	mov    eax,edx
    122a:	01 c0                	add    eax,eax
    122c:	01 d0                	add    eax,edx
    122e:	01 45 f4             	add    DWORD PTR [rbp-0xc],eax
    1231:	83 45 f8 01          	add    DWORD PTR [rbp-0x8],0x1
    1235:	83 7d f8 09          	cmp    DWORD PTR [rbp-0x8],0x9
    1239:	7e ea                	jle    1225 <compute_with_expensive_ops+0x7c>
    123b:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    123e:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    1241:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    1244:	5d                   	pop    rbp
    1245:	c3                   	ret

0000000000001246 <compute_optimized>:
    1246:	f3 0f 1e fa          	endbr64
    124a:	55                   	push   rbp
    124b:	48 89 e5             	mov    rbp,rsp
    124e:	89 7d ec             	mov    DWORD PTR [rbp-0x14],edi
    1251:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
    1258:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    125b:	01 c0                	add    eax,eax
    125d:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    1260:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    1263:	c1 e0 02             	shl    eax,0x2
    1266:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    1269:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    126c:	c1 e0 03             	shl    eax,0x3
    126f:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    1272:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    1275:	c1 e0 04             	shl    eax,0x4
    1278:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    127b:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    127e:	d1 f8                	sar    eax,1
    1280:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    1283:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    1286:	c1 f8 02             	sar    eax,0x2
    1289:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    128c:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    128f:	83 e0 07             	and    eax,0x7
    1292:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    1295:	c7 45 f0 00 00 00 00 	mov    DWORD PTR [rbp-0x10],0x0
    129c:	c7 45 f4 00 00 00 00 	mov    DWORD PTR [rbp-0xc],0x0
    12a3:	c7 45 f8 00 00 00 00 	mov    DWORD PTR [rbp-0x8],0x0
    12aa:	eb 0e                	jmp    12ba <compute_optimized+0x74>
    12ac:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    12af:	01 45 f0             	add    DWORD PTR [rbp-0x10],eax
    12b2:	83 45 f4 03          	add    DWORD PTR [rbp-0xc],0x3
    12b6:	83 45 f8 01          	add    DWORD PTR [rbp-0x8],0x1
    12ba:	83 7d f8 09          	cmp    DWORD PTR [rbp-0x8],0x9
    12be:	7e ec                	jle    12ac <compute_optimized+0x66>
    12c0:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
    12c3:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    12c6:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    12c9:	5d                   	pop    rbp
    12ca:	c3                   	ret

00000000000012cb <benchmark_strength_reduction>:
    12cb:	f3 0f 1e fa          	endbr64
    12cf:	55                   	push   rbp
    12d0:	48 89 e5             	mov    rbp,rsp
    12d3:	48 83 ec 10          	sub    rsp,0x10
    12d7:	48 c7 45 f8 00 00 00 	mov    QWORD PTR [rbp-0x8],0x0
    12de:	00 
    12df:	c7 45 f4 00 00 00 00 	mov    DWORD PTR [rbp-0xc],0x0
    12e6:	eb 14                	jmp    12fc <benchmark_strength_reduction+0x31>
    12e8:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    12eb:	89 c7                	mov    edi,eax
    12ed:	e8 b7 fe ff ff       	call   11a9 <compute_with_expensive_ops>
    12f2:	48 98                	cdqe
    12f4:	48 01 45 f8          	add    QWORD PTR [rbp-0x8],rax
    12f8:	83 45 f4 01          	add    DWORD PTR [rbp-0xc],0x1
    12fc:	81 7d f4 ff e0 f5 05 	cmp    DWORD PTR [rbp-0xc],0x5f5e0ff
    1303:	7e e3                	jle    12e8 <benchmark_strength_reduction+0x1d>
    1305:	48 8b 45 f8          	mov    rax,QWORD PTR [rbp-0x8]
    1309:	c9                   	leave
    130a:	c3                   	ret

000000000000130b <main>:
    130b:	f3 0f 1e fa          	endbr64
    130f:	55                   	push   rbp
    1310:	48 89 e5             	mov    rbp,rsp
    1313:	48 83 ec 40          	sub    rsp,0x40
    1317:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    131e:	00 00 
    1320:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax
    1324:	31 c0                	xor    eax,eax
    1326:	b8 00 00 00 00       	mov    eax,0x0
    132b:	e8 9b ff ff ff       	call   12cb <benchmark_strength_reduction>
    1330:	48 89 45 c0          	mov    QWORD PTR [rbp-0x40],rax
    1334:	48 8d 45 d0          	lea    rax,[rbp-0x30]
    1338:	48 89 c6             	mov    rsi,rax
    133b:	bf 01 00 00 00       	mov    edi,0x1
    1340:	e8 4b fd ff ff       	call   1090 <clock_gettime@plt>
    1345:	b8 00 00 00 00       	mov    eax,0x0
    134a:	e8 7c ff ff ff       	call   12cb <benchmark_strength_reduction>
    134f:	48 89 45 c0          	mov    QWORD PTR [rbp-0x40],rax
    1353:	48 8d 45 e0          	lea    rax,[rbp-0x20]
    1357:	48 89 c6             	mov    rsi,rax
    135a:	bf 01 00 00 00       	mov    edi,0x1
    135f:	e8 2c fd ff ff       	call   1090 <clock_gettime@plt>
    1364:	48 8b 55 e0          	mov    rdx,QWORD PTR [rbp-0x20]
    1368:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    136c:	48 29 c2             	sub    rdx,rax
    136f:	66 0f ef c9          	pxor   xmm1,xmm1
    1373:	f2 48 0f 2a ca       	cvtsi2sd xmm1,rdx
    1378:	48 8b 55 e8          	mov    rdx,QWORD PTR [rbp-0x18]
    137c:	48 8b 45 d8          	mov    rax,QWORD PTR [rbp-0x28]
    1380:	48 29 c2             	sub    rdx,rax
    1383:	66 0f ef c0          	pxor   xmm0,xmm0
    1387:	f2 48 0f 2a c2       	cvtsi2sd xmm0,rdx
    138c:	f2 0f 10 15 c4 0c 00 	movsd  xmm2,QWORD PTR [rip+0xcc4]        # 2058 <_IO_stdin_used+0x58>
    1393:	00 
    1394:	f2 0f 5e c2          	divsd  xmm0,xmm2
    1398:	f2 0f 58 c1          	addsd  xmm0,xmm1
    139c:	f2 0f 11 45 c8       	movsd  QWORD PTR [rbp-0x38],xmm0
    13a1:	48 8d 05 60 0c 00 00 	lea    rax,[rip+0xc60]        # 2008 <_IO_stdin_used+0x8>
    13a8:	48 89 c7             	mov    rdi,rax
    13ab:	e8 d0 fc ff ff       	call   1080 <puts@plt>
    13b0:	48 8b 45 c0          	mov    rax,QWORD PTR [rbp-0x40]
    13b4:	48 89 c6             	mov    rsi,rax
    13b7:	48 8d 05 62 0c 00 00 	lea    rax,[rip+0xc62]        # 2020 <_IO_stdin_used+0x20>
    13be:	48 89 c7             	mov    rdi,rax
    13c1:	b8 00 00 00 00       	mov    eax,0x0
    13c6:	e8 e5 fc ff ff       	call   10b0 <printf@plt>
    13cb:	48 8b 45 c8          	mov    rax,QWORD PTR [rbp-0x38]
    13cf:	66 48 0f 6e c0       	movq   xmm0,rax
    13d4:	48 8d 05 52 0c 00 00 	lea    rax,[rip+0xc52]        # 202d <_IO_stdin_used+0x2d>
    13db:	48 89 c7             	mov    rdi,rax
    13de:	b8 01 00 00 00       	mov    eax,0x1
    13e3:	e8 c8 fc ff ff       	call   10b0 <printf@plt>
    13e8:	be 00 e1 f5 05       	mov    esi,0x5f5e100
    13ed:	48 8d 05 4d 0c 00 00 	lea    rax,[rip+0xc4d]        # 2041 <_IO_stdin_used+0x41>
    13f4:	48 89 c7             	mov    rdi,rax
    13f7:	b8 00 00 00 00       	mov    eax,0x0
    13fc:	e8 af fc ff ff       	call   10b0 <printf@plt>
    1401:	b8 00 00 00 00       	mov    eax,0x0
    1406:	48 8b 55 f8          	mov    rdx,QWORD PTR [rbp-0x8]
    140a:	64 48 2b 14 25 28 00 	sub    rdx,QWORD PTR fs:0x28
    1411:	00 00 
    1413:	74 05                	je     141a <main+0x10f>
    1415:	e8 86 fc ff ff       	call   10a0 <__stack_chk_fail@plt>
    141a:	c9                   	leave
    141b:	c3                   	ret

Disassembly of section .fini:

000000000000141c <_fini>:
    141c:	f3 0f 1e fa          	endbr64
    1420:	48 83 ec 08          	sub    rsp,0x8
    1424:	48 83 c4 08          	add    rsp,0x8
    1428:	c3                   	ret
