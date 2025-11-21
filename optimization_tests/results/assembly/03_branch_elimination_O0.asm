
build/03_branch_elimination_O0:     file format elf64-x86-64


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
    10d8:	48 8d 3d 74 01 00 00 	lea    rdi,[rip+0x174]        # 1253 <main>
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

00000000000011a9 <compute_with_known_branch>:
    11a9:	f3 0f 1e fa          	endbr64
    11ad:	55                   	push   rbp
    11ae:	48 89 e5             	mov    rbp,rsp
    11b1:	89 7d ec             	mov    DWORD PTR [rbp-0x14],edi
    11b4:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    11b7:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    11ba:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    11bd:	83 c0 05             	add    eax,0x5
    11c0:	01 c0                	add    eax,eax
    11c2:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    11c5:	83 45 fc 05          	add    DWORD PTR [rbp-0x4],0x5
    11c9:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    11cc:	5d                   	pop    rbp
    11cd:	c3                   	ret

00000000000011ce <compute_with_runtime_branch>:
    11ce:	f3 0f 1e fa          	endbr64
    11d2:	55                   	push   rbp
    11d3:	48 89 e5             	mov    rbp,rsp
    11d6:	89 7d ec             	mov    DWORD PTR [rbp-0x14],edi
    11d9:	89 75 e8             	mov    DWORD PTR [rbp-0x18],esi
    11dc:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    11df:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    11e2:	83 7d e8 00          	cmp    DWORD PTR [rbp-0x18],0x0
    11e6:	74 0d                	je     11f5 <compute_with_runtime_branch+0x27>
    11e8:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    11eb:	83 c0 05             	add    eax,0x5
    11ee:	01 c0                	add    eax,eax
    11f0:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    11f3:	eb 0f                	jmp    1204 <compute_with_runtime_branch+0x36>
    11f5:	8b 55 fc             	mov    edx,DWORD PTR [rbp-0x4]
    11f8:	89 d0                	mov    eax,edx
    11fa:	01 c0                	add    eax,eax
    11fc:	01 d0                	add    eax,edx
    11fe:	83 c0 14             	add    eax,0x14
    1201:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    1204:	83 7d e8 01          	cmp    DWORD PTR [rbp-0x18],0x1
    1208:	75 04                	jne    120e <compute_with_runtime_branch+0x40>
    120a:	83 45 fc 05          	add    DWORD PTR [rbp-0x4],0x5
    120e:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    1211:	5d                   	pop    rbp
    1212:	c3                   	ret

0000000000001213 <benchmark_branch_elimination>:
    1213:	f3 0f 1e fa          	endbr64
    1217:	55                   	push   rbp
    1218:	48 89 e5             	mov    rbp,rsp
    121b:	48 83 ec 10          	sub    rsp,0x10
    121f:	48 c7 45 f8 00 00 00 	mov    QWORD PTR [rbp-0x8],0x0
    1226:	00 
    1227:	c7 45 f4 00 00 00 00 	mov    DWORD PTR [rbp-0xc],0x0
    122e:	eb 14                	jmp    1244 <benchmark_branch_elimination+0x31>
    1230:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    1233:	89 c7                	mov    edi,eax
    1235:	e8 6f ff ff ff       	call   11a9 <compute_with_known_branch>
    123a:	48 98                	cdqe
    123c:	48 01 45 f8          	add    QWORD PTR [rbp-0x8],rax
    1240:	83 45 f4 01          	add    DWORD PTR [rbp-0xc],0x1
    1244:	81 7d f4 ff e0 f5 05 	cmp    DWORD PTR [rbp-0xc],0x5f5e0ff
    124b:	7e e3                	jle    1230 <benchmark_branch_elimination+0x1d>
    124d:	48 8b 45 f8          	mov    rax,QWORD PTR [rbp-0x8]
    1251:	c9                   	leave
    1252:	c3                   	ret

0000000000001253 <main>:
    1253:	f3 0f 1e fa          	endbr64
    1257:	55                   	push   rbp
    1258:	48 89 e5             	mov    rbp,rsp
    125b:	48 83 ec 40          	sub    rsp,0x40
    125f:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    1266:	00 00 
    1268:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax
    126c:	31 c0                	xor    eax,eax
    126e:	b8 00 00 00 00       	mov    eax,0x0
    1273:	e8 9b ff ff ff       	call   1213 <benchmark_branch_elimination>
    1278:	48 89 45 c0          	mov    QWORD PTR [rbp-0x40],rax
    127c:	48 8d 45 d0          	lea    rax,[rbp-0x30]
    1280:	48 89 c6             	mov    rsi,rax
    1283:	bf 01 00 00 00       	mov    edi,0x1
    1288:	e8 03 fe ff ff       	call   1090 <clock_gettime@plt>
    128d:	b8 00 00 00 00       	mov    eax,0x0
    1292:	e8 7c ff ff ff       	call   1213 <benchmark_branch_elimination>
    1297:	48 89 45 c0          	mov    QWORD PTR [rbp-0x40],rax
    129b:	48 8d 45 e0          	lea    rax,[rbp-0x20]
    129f:	48 89 c6             	mov    rsi,rax
    12a2:	bf 01 00 00 00       	mov    edi,0x1
    12a7:	e8 e4 fd ff ff       	call   1090 <clock_gettime@plt>
    12ac:	48 8b 55 e0          	mov    rdx,QWORD PTR [rbp-0x20]
    12b0:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    12b4:	48 29 c2             	sub    rdx,rax
    12b7:	66 0f ef c9          	pxor   xmm1,xmm1
    12bb:	f2 48 0f 2a ca       	cvtsi2sd xmm1,rdx
    12c0:	48 8b 55 e8          	mov    rdx,QWORD PTR [rbp-0x18]
    12c4:	48 8b 45 d8          	mov    rax,QWORD PTR [rbp-0x28]
    12c8:	48 29 c2             	sub    rdx,rax
    12cb:	66 0f ef c0          	pxor   xmm0,xmm0
    12cf:	f2 48 0f 2a c2       	cvtsi2sd xmm0,rdx
    12d4:	f2 0f 10 15 7c 0d 00 	movsd  xmm2,QWORD PTR [rip+0xd7c]        # 2058 <_IO_stdin_used+0x58>
    12db:	00 
    12dc:	f2 0f 5e c2          	divsd  xmm0,xmm2
    12e0:	f2 0f 58 c1          	addsd  xmm0,xmm1
    12e4:	f2 0f 11 45 c8       	movsd  QWORD PTR [rbp-0x38],xmm0
    12e9:	48 8d 05 18 0d 00 00 	lea    rax,[rip+0xd18]        # 2008 <_IO_stdin_used+0x8>
    12f0:	48 89 c7             	mov    rdi,rax
    12f3:	e8 88 fd ff ff       	call   1080 <puts@plt>
    12f8:	48 8b 45 c0          	mov    rax,QWORD PTR [rbp-0x40]
    12fc:	48 89 c6             	mov    rsi,rax
    12ff:	48 8d 05 1a 0d 00 00 	lea    rax,[rip+0xd1a]        # 2020 <_IO_stdin_used+0x20>
    1306:	48 89 c7             	mov    rdi,rax
    1309:	b8 00 00 00 00       	mov    eax,0x0
    130e:	e8 9d fd ff ff       	call   10b0 <printf@plt>
    1313:	48 8b 45 c8          	mov    rax,QWORD PTR [rbp-0x38]
    1317:	66 48 0f 6e c0       	movq   xmm0,rax
    131c:	48 8d 05 0a 0d 00 00 	lea    rax,[rip+0xd0a]        # 202d <_IO_stdin_used+0x2d>
    1323:	48 89 c7             	mov    rdi,rax
    1326:	b8 01 00 00 00       	mov    eax,0x1
    132b:	e8 80 fd ff ff       	call   10b0 <printf@plt>
    1330:	be 00 e1 f5 05       	mov    esi,0x5f5e100
    1335:	48 8d 05 05 0d 00 00 	lea    rax,[rip+0xd05]        # 2041 <_IO_stdin_used+0x41>
    133c:	48 89 c7             	mov    rdi,rax
    133f:	b8 00 00 00 00       	mov    eax,0x0
    1344:	e8 67 fd ff ff       	call   10b0 <printf@plt>
    1349:	b8 00 00 00 00       	mov    eax,0x0
    134e:	48 8b 55 f8          	mov    rdx,QWORD PTR [rbp-0x8]
    1352:	64 48 2b 14 25 28 00 	sub    rdx,QWORD PTR fs:0x28
    1359:	00 00 
    135b:	74 05                	je     1362 <main+0x10f>
    135d:	e8 3e fd ff ff       	call   10a0 <__stack_chk_fail@plt>
    1362:	c9                   	leave
    1363:	c3                   	ret

Disassembly of section .fini:

0000000000001364 <_fini>:
    1364:	f3 0f 1e fa          	endbr64
    1368:	48 83 ec 08          	sub    rsp,0x8
    136c:	48 83 c4 08          	add    rsp,0x8
    1370:	c3                   	ret
