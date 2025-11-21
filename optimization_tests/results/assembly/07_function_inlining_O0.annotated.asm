
build/07_function_inlining_O0:     file format elf64-x86-64


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
    10d8:	48 8d 3d 6f 02 00 00 	lea    rdi,[rip+0x26f]        # 134e <main>
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

00000000000011a9 <add>:
    11a9:	55                   	push   rbp
    11aa:	48 89 e5             	mov    rbp,rsp
    11ad:	89 7d fc             	mov    DWORD PTR [rbp-0x4],edi
    11b0:	89 75 f8             	mov    DWORD PTR [rbp-0x8],esi
    11b3:	8b 55 fc             	mov    edx,DWORD PTR [rbp-0x4]
    11b6:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]
    11b9:	01 d0                	add    eax,edx
    11bb:	5d                   	pop    rbp
    11bc:	c3                   	ret

00000000000011bd <multiply>:
    11bd:	55                   	push   rbp
    11be:	48 89 e5             	mov    rbp,rsp
    11c1:	89 7d fc             	mov    DWORD PTR [rbp-0x4],edi
    11c4:	89 75 f8             	mov    DWORD PTR [rbp-0x8],esi
    11c7:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    11ca:	0f af 45 f8          	imul   eax,DWORD PTR [rbp-0x8]
    11ce:	5d                   	pop    rbp
    11cf:	c3                   	ret

00000000000011d0 <square>:
    11d0:	55                   	push   rbp
    11d1:	48 89 e5             	mov    rbp,rsp
    11d4:	89 7d fc             	mov    DWORD PTR [rbp-0x4],edi
    11d7:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    11da:	0f af c0             	imul   eax,eax
    11dd:	5d                   	pop    rbp
    11de:	c3                   	ret

00000000000011df <calculate>:
    11df:	55                   	push   rbp
    11e0:	48 89 e5             	mov    rbp,rsp
    11e3:	89 7d fc             	mov    DWORD PTR [rbp-0x4],edi
    11e6:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    11e9:	83 c0 05             	add    eax,0x5
    11ec:	01 c0                	add    eax,eax
    11ee:	5d                   	pop    rbp
    11ef:	c3                   	ret

00000000000011f0 <compute_with_calls>:
    11f0:	f3 0f 1e fa          	endbr64
    11f4:	55                   	push   rbp
    11f5:	48 89 e5             	mov    rbp,rsp
    11f8:	48 83 ec 18          	sub    rsp,0x18
    11fc:	89 7d ec             	mov    DWORD PTR [rbp-0x14],edi
    11ff:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
    1206:	8b 55 ec             	mov    edx,DWORD PTR [rbp-0x14]
    1209:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    120c:	89 d6                	mov    esi,edx
    120e:	89 c7                	mov    edi,eax
    1210:	e8 94 ff ff ff       	call   11a9 <add>
    1215:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    1218:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    121b:	be 02 00 00 00       	mov    esi,0x2
    1220:	89 c7                	mov    edi,eax
    1222:	e8 96 ff ff ff       	call   11bd <multiply>
    1227:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    122a:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    122d:	89 c7                	mov    edi,eax
    122f:	e8 9c ff ff ff       	call   11d0 <square>
    1234:	89 c2                	mov    edx,eax
    1236:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    1239:	89 d6                	mov    esi,edx
    123b:	89 c7                	mov    edi,eax
    123d:	e8 67 ff ff ff       	call   11a9 <add>
    1242:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    1245:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    1248:	89 c7                	mov    edi,eax
    124a:	e8 90 ff ff ff       	call   11df <calculate>
    124f:	89 c2                	mov    edx,eax
    1251:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    1254:	89 d6                	mov    esi,edx
    1256:	89 c7                	mov    edi,eax
    1258:	e8 4c ff ff ff       	call   11a9 <add>
    125d:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    1260:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    1263:	c9                   	leave
    1264:	c3                   	ret

0000000000001265 <larger_function>:
    1265:	f3 0f 1e fa          	endbr64
    1269:	55                   	push   rbp
    126a:	48 89 e5             	mov    rbp,rsp
    126d:	89 7d ec             	mov    DWORD PTR [rbp-0x14],edi
    1270:	89 75 e8             	mov    DWORD PTR [rbp-0x18],esi
    1273:	c7 45 f8 00 00 00 00 	mov    DWORD PTR [rbp-0x8],0x0
    127a:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
    1281:	eb 1d                	jmp    12a0 <larger_function+0x3b>
    1283:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    1286:	0f af 45 fc          	imul   eax,DWORD PTR [rbp-0x4]
    128a:	01 45 f8             	add    DWORD PTR [rbp-0x8],eax
    128d:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    1290:	8d 48 01             	lea    ecx,[rax+0x1]
    1293:	8b 45 e8             	mov    eax,DWORD PTR [rbp-0x18]
    1296:	99                   	cdq
    1297:	f7 f9                	idiv   ecx
    1299:	29 45 f8             	sub    DWORD PTR [rbp-0x8],eax
    129c:	83 45 fc 01          	add    DWORD PTR [rbp-0x4],0x1
    12a0:	83 7d fc 04          	cmp    DWORD PTR [rbp-0x4],0x4
    12a4:	7e dd                	jle    1283 <larger_function+0x1e>
    12a6:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]
    12a9:	5d                   	pop    rbp
    12aa:	c3                   	ret

00000000000012ab <compute_with_larger_call>:
    12ab:	f3 0f 1e fa          	endbr64
    12af:	55                   	push   rbp
    12b0:	48 89 e5             	mov    rbp,rsp
    12b3:	48 83 ec 08          	sub    rsp,0x8
    12b7:	89 7d fc             	mov    DWORD PTR [rbp-0x4],edi
    12ba:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    12bd:	8d 50 01             	lea    edx,[rax+0x1]
    12c0:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    12c3:	89 d6                	mov    esi,edx
    12c5:	89 c7                	mov    edi,eax
    12c7:	e8 99 ff ff ff       	call   1265 <larger_function>
    12cc:	c9                   	leave
    12cd:	c3                   	ret

00000000000012ce <benchmark_inlining>:
    12ce:	f3 0f 1e fa          	endbr64
    12d2:	55                   	push   rbp
    12d3:	48 89 e5             	mov    rbp,rsp
    12d6:	48 83 ec 10          	sub    rsp,0x10
    12da:	48 c7 45 f8 00 00 00 	mov    QWORD PTR [rbp-0x8],0x0
    12e1:	00 
    12e2:	c7 45 f4 00 00 00 00 	mov    DWORD PTR [rbp-0xc],0x0
    12e9:	eb 14                	jmp    12ff <benchmark_inlining+0x31>
    12eb:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    12ee:	89 c7                	mov    edi,eax
    12f0:	e8 fb fe ff ff       	call   11f0 <compute_with_calls>
    12f5:	48 98                	cdqe
    12f7:	48 01 45 f8          	add    QWORD PTR [rbp-0x8],rax
    12fb:	83 45 f4 01          	add    DWORD PTR [rbp-0xc],0x1
    12ff:	81 7d f4 ff e0 f5 05 	cmp    DWORD PTR [rbp-0xc],0x5f5e0ff
    1306:	7e e3                	jle    12eb <benchmark_inlining+0x1d>
    1308:	48 8b 45 f8          	mov    rax,QWORD PTR [rbp-0x8]
    130c:	c9                   	leave
    130d:	c3                   	ret

000000000000130e <benchmark_larger_calls>:
    130e:	f3 0f 1e fa          	endbr64
    1312:	55                   	push   rbp
    1313:	48 89 e5             	mov    rbp,rsp
    1316:	48 83 ec 10          	sub    rsp,0x10
    131a:	48 c7 45 f8 00 00 00 	mov    QWORD PTR [rbp-0x8],0x0
    1321:	00 
    1322:	c7 45 f4 00 00 00 00 	mov    DWORD PTR [rbp-0xc],0x0
    1329:	eb 14                	jmp    133f <benchmark_larger_calls+0x31>
    132b:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    132e:	89 c7                	mov    edi,eax
    1330:	e8 76 ff ff ff       	call   12ab <compute_with_larger_call>
    1335:	48 98                	cdqe
    1337:	48 01 45 f8          	add    QWORD PTR [rbp-0x8],rax
    133b:	83 45 f4 01          	add    DWORD PTR [rbp-0xc],0x1
    133f:	81 7d f4 7f 96 98 00 	cmp    DWORD PTR [rbp-0xc],0x98967f
    1346:	7e e3                	jle    132b <benchmark_larger_calls+0x1d>
    1348:	48 8b 45 f8          	mov    rax,QWORD PTR [rbp-0x8]
    134c:	c9                   	leave
    134d:	c3                   	ret

000000000000134e <main>:
    134e:	f3 0f 1e fa          	endbr64
    1352:	55                   	push   rbp
    1353:	48 89 e5             	mov    rbp,rsp
    1356:	48 83 ec 50          	sub    rsp,0x50
    135a:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    1361:	00 00 
    1363:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax
    1367:	31 c0                	xor    eax,eax
    1369:	b8 00 00 00 00       	mov    eax,0x0
    136e:	e8 5b ff ff ff       	call   12ce <benchmark_inlining>
    1373:	48 89 45 b8          	mov    QWORD PTR [rbp-0x48],rax
    1377:	48 8d 45 d0          	lea    rax,[rbp-0x30]
    137b:	48 89 c6             	mov    rsi,rax
    137e:	bf 01 00 00 00       	mov    edi,0x1
    1383:	e8 08 fd ff ff       	call   1090 <clock_gettime@plt>
    1388:	b8 00 00 00 00       	mov    eax,0x0
    138d:	e8 3c ff ff ff       	call   12ce <benchmark_inlining>
    1392:	48 89 45 b8          	mov    QWORD PTR [rbp-0x48],rax
    1396:	48 8d 45 e0          	lea    rax,[rbp-0x20]
    139a:	48 89 c6             	mov    rsi,rax
    139d:	bf 01 00 00 00       	mov    edi,0x1
    13a2:	e8 e9 fc ff ff       	call   1090 <clock_gettime@plt>
    13a7:	48 8b 55 e0          	mov    rdx,QWORD PTR [rbp-0x20]
    13ab:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    13af:	48 29 c2             	sub    rdx,rax
    13b2:	66 0f ef c9          	pxor   xmm1,xmm1
    13b6:	f2 48 0f 2a ca       	cvtsi2sd xmm1,rdx
    13bb:	48 8b 55 e8          	mov    rdx,QWORD PTR [rbp-0x18]
    13bf:	48 8b 45 d8          	mov    rax,QWORD PTR [rbp-0x28]
    13c3:	48 29 c2             	sub    rdx,rax
    13c6:	66 0f ef c0          	pxor   xmm0,xmm0
    13ca:	f2 48 0f 2a c2       	cvtsi2sd xmm0,rdx
    13cf:	f2 0f 10 15 c9 0c 00 	movsd  xmm2,QWORD PTR [rip+0xcc9]        # 20a0 <_IO_stdin_used+0xa0>
    13d6:	00 
    13d7:	f2 0f 5e c2          	divsd  xmm0,xmm2
    13db:	f2 0f 58 c1          	addsd  xmm0,xmm1
    13df:	f2 0f 11 45 c0       	movsd  QWORD PTR [rbp-0x40],xmm0
    13e4:	48 8d 45 d0          	lea    rax,[rbp-0x30]
    13e8:	48 89 c6             	mov    rsi,rax
    13eb:	bf 01 00 00 00       	mov    edi,0x1
    13f0:	e8 9b fc ff ff       	call   1090 <clock_gettime@plt>
    13f5:	b8 00 00 00 00       	mov    eax,0x0
    13fa:	e8 0f ff ff ff       	call   130e <benchmark_larger_calls>
    13ff:	48 89 45 b8          	mov    QWORD PTR [rbp-0x48],rax
    1403:	48 8d 45 e0          	lea    rax,[rbp-0x20]
    1407:	48 89 c6             	mov    rsi,rax
    140a:	bf 01 00 00 00       	mov    edi,0x1
    140f:	e8 7c fc ff ff       	call   1090 <clock_gettime@plt>
    1414:	48 8b 55 e0          	mov    rdx,QWORD PTR [rbp-0x20]
    1418:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    141c:	48 29 c2             	sub    rdx,rax
    141f:	66 0f ef c9          	pxor   xmm1,xmm1
    1423:	f2 48 0f 2a ca       	cvtsi2sd xmm1,rdx
    1428:	48 8b 55 e8          	mov    rdx,QWORD PTR [rbp-0x18]
    142c:	48 8b 45 d8          	mov    rax,QWORD PTR [rbp-0x28]
    1430:	48 29 c2             	sub    rdx,rax
    1433:	66 0f ef c0          	pxor   xmm0,xmm0
    1437:	f2 48 0f 2a c2       	cvtsi2sd xmm0,rdx
    143c:	f2 0f 10 15 5c 0c 00 	movsd  xmm2,QWORD PTR [rip+0xc5c]        # 20a0 <_IO_stdin_used+0xa0>
    1443:	00 
    1444:	f2 0f 5e c2          	divsd  xmm0,xmm2
    1448:	f2 0f 58 c1          	addsd  xmm0,xmm1
    144c:	f2 0f 11 45 c8       	movsd  QWORD PTR [rbp-0x38],xmm0
    1451:	48 8d 05 b0 0b 00 00 	lea    rax,[rip+0xbb0]        # 2008 <_IO_stdin_used+0x8>
    1458:	48 89 c7             	mov    rdi,rax
    145b:	e8 20 fc ff ff       	call   1080 <puts@plt>
    1460:	48 8b 45 c0          	mov    rax,QWORD PTR [rbp-0x40]
    1464:	be 00 e1 f5 05       	mov    esi,0x5f5e100
    1469:	66 48 0f 6e c0       	movq   xmm0,rax
    146e:	48 8d 05 ab 0b 00 00 	lea    rax,[rip+0xbab]        # 2020 <_IO_stdin_used+0x20>
    1475:	48 89 c7             	mov    rdi,rax
    1478:	b8 01 00 00 00       	mov    eax,0x1
    147d:	e8 2e fc ff ff       	call   10b0 <printf@plt>
    1482:	48 8b 45 c8          	mov    rax,QWORD PTR [rbp-0x38]
    1486:	be 80 96 98 00       	mov    esi,0x989680
    148b:	66 48 0f 6e c0       	movq   xmm0,rax
    1490:	48 8d 05 c1 0b 00 00 	lea    rax,[rip+0xbc1]        # 2058 <_IO_stdin_used+0x58>
    1497:	48 89 c7             	mov    rdi,rax
    149a:	b8 01 00 00 00       	mov    eax,0x1
    149f:	e8 0c fc ff ff       	call   10b0 <printf@plt>
    14a4:	48 8b 45 b8          	mov    rax,QWORD PTR [rbp-0x48]
    14a8:	48 89 c6             	mov    rsi,rax
    14ab:	48 8d 05 da 0b 00 00 	lea    rax,[rip+0xbda]        # 208c <_IO_stdin_used+0x8c>
    14b2:	48 89 c7             	mov    rdi,rax
    14b5:	b8 00 00 00 00       	mov    eax,0x0
    14ba:	e8 f1 fb ff ff       	call   10b0 <printf@plt>
    14bf:	b8 00 00 00 00       	mov    eax,0x0
    14c4:	48 8b 55 f8          	mov    rdx,QWORD PTR [rbp-0x8]
    14c8:	64 48 2b 14 25 28 00 	sub    rdx,QWORD PTR fs:0x28
    14cf:	00 00 
    14d1:	74 05                	je     14d8 <main+0x18a>
    14d3:	e8 c8 fb ff ff       	call   10a0 <__stack_chk_fail@plt>
    14d8:	c9                   	leave
    14d9:	c3                   	ret

Disassembly of section .fini:

00000000000014dc <_fini>:
    14dc:	f3 0f 1e fa          	endbr64
    14e0:	48 83 ec 08          	sub    rsp,0x8
    14e4:	48 83 c4 08          	add    rsp,0x8
    14e8:	c3                   	ret
