
build/02_loop_unrolling_O0:     file format elf64-x86-64


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
    10d8:	48 8d 3d 27 02 00 00 	lea    rdi,[rip+0x227]        # 1306 <main>
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

00000000000011a9 <sum_small_array>:
    11a9:	f3 0f 1e fa          	endbr64
    11ad:	55                   	push   rbp
    11ae:	48 89 e5             	mov    rbp,rsp
    11b1:	48 89 7d e8          	mov    QWORD PTR [rbp-0x18],rdi
    11b5:	c7 45 f8 00 00 00 00 	mov    DWORD PTR [rbp-0x8],0x0
    11bc:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
    11c3:	eb 1d                	jmp    11e2 <sum_small_array+0x39>
    11c5:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    11c8:	48 98                	cdqe
    11ca:	48 8d 14 85 00 00 00 	lea    rdx,[rax*4+0x0]
    11d1:	00 
    11d2:	48 8b 45 e8          	mov    rax,QWORD PTR [rbp-0x18]
    11d6:	48 01 d0             	add    rax,rdx
    11d9:	8b 00                	mov    eax,DWORD PTR [rax]
    11db:	01 45 f8             	add    DWORD PTR [rbp-0x8],eax
    11de:	83 45 fc 01          	add    DWORD PTR [rbp-0x4],0x1
    11e2:	83 7d fc 07          	cmp    DWORD PTR [rbp-0x4],0x7
    11e6:	7e dd                	jle    11c5 <sum_small_array+0x1c>
    11e8:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]
    11eb:	5d                   	pop    rbp
    11ec:	c3                   	ret

00000000000011ed <process_array>:
    11ed:	f3 0f 1e fa          	endbr64
    11f1:	55                   	push   rbp
    11f2:	48 89 e5             	mov    rbp,rsp
    11f5:	48 89 7d e8          	mov    QWORD PTR [rbp-0x18],rdi
    11f9:	c7 45 f8 00 00 00 00 	mov    DWORD PTR [rbp-0x8],0x0
    1200:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
    1207:	eb 43                	jmp    124c <process_array+0x5f>
    1209:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    120c:	48 98                	cdqe
    120e:	48 8d 14 85 00 00 00 	lea    rdx,[rax*4+0x0]
    1215:	00 
    1216:	48 8b 45 e8          	mov    rax,QWORD PTR [rbp-0x18]
    121a:	48 01 d0             	add    rax,rdx
    121d:	8b 00                	mov    eax,DWORD PTR [rax]
    121f:	01 c0                	add    eax,eax
    1221:	01 45 f8             	add    DWORD PTR [rbp-0x8],eax
    1224:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    1227:	48 98                	cdqe
    1229:	48 8d 14 85 00 00 00 	lea    rdx,[rax*4+0x0]
    1230:	00 
    1231:	48 8b 45 e8          	mov    rax,QWORD PTR [rbp-0x18]
    1235:	48 01 d0             	add    rax,rdx
    1238:	8b 00                	mov    eax,DWORD PTR [rax]
    123a:	89 c2                	mov    edx,eax
    123c:	c1 ea 1f             	shr    edx,0x1f
    123f:	01 d0                	add    eax,edx
    1241:	d1 f8                	sar    eax,1
    1243:	f7 d8                	neg    eax
    1245:	01 45 f8             	add    DWORD PTR [rbp-0x8],eax
    1248:	83 45 fc 01          	add    DWORD PTR [rbp-0x4],0x1
    124c:	83 7d fc 07          	cmp    DWORD PTR [rbp-0x4],0x7
    1250:	7e b7                	jle    1209 <process_array+0x1c>
    1252:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]
    1255:	5d                   	pop    rbp
    1256:	c3                   	ret

0000000000001257 <benchmark_loop_unrolling>:
    1257:	f3 0f 1e fa          	endbr64
    125b:	55                   	push   rbp
    125c:	48 89 e5             	mov    rbp,rsp
    125f:	48 83 ec 40          	sub    rsp,0x40
    1263:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    126a:	00 00 
    126c:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax
    1270:	31 c0                	xor    eax,eax
    1272:	c7 45 d0 01 00 00 00 	mov    DWORD PTR [rbp-0x30],0x1
    1279:	c7 45 d4 02 00 00 00 	mov    DWORD PTR [rbp-0x2c],0x2
    1280:	c7 45 d8 03 00 00 00 	mov    DWORD PTR [rbp-0x28],0x3
    1287:	c7 45 dc 04 00 00 00 	mov    DWORD PTR [rbp-0x24],0x4
    128e:	c7 45 e0 05 00 00 00 	mov    DWORD PTR [rbp-0x20],0x5
    1295:	c7 45 e4 06 00 00 00 	mov    DWORD PTR [rbp-0x1c],0x6
    129c:	c7 45 e8 07 00 00 00 	mov    DWORD PTR [rbp-0x18],0x7
    12a3:	c7 45 ec 08 00 00 00 	mov    DWORD PTR [rbp-0x14],0x8
    12aa:	48 c7 45 c8 00 00 00 	mov    QWORD PTR [rbp-0x38],0x0
    12b1:	00 
    12b2:	c7 45 c4 00 00 00 00 	mov    DWORD PTR [rbp-0x3c],0x0
    12b9:	eb 28                	jmp    12e3 <benchmark_loop_unrolling+0x8c>
    12bb:	48 8d 45 d0          	lea    rax,[rbp-0x30]
    12bf:	48 89 c7             	mov    rdi,rax
    12c2:	e8 e2 fe ff ff       	call   11a9 <sum_small_array>
    12c7:	48 98                	cdqe
    12c9:	48 01 45 c8          	add    QWORD PTR [rbp-0x38],rax
    12cd:	48 8d 45 d0          	lea    rax,[rbp-0x30]
    12d1:	48 89 c7             	mov    rdi,rax
    12d4:	e8 14 ff ff ff       	call   11ed <process_array>
    12d9:	48 98                	cdqe
    12db:	48 01 45 c8          	add    QWORD PTR [rbp-0x38],rax
    12df:	83 45 c4 01          	add    DWORD PTR [rbp-0x3c],0x1
    12e3:	81 7d c4 7f 96 98 00 	cmp    DWORD PTR [rbp-0x3c],0x98967f
    12ea:	7e cf                	jle    12bb <benchmark_loop_unrolling+0x64>
    12ec:	48 8b 45 c8          	mov    rax,QWORD PTR [rbp-0x38]
    12f0:	48 8b 55 f8          	mov    rdx,QWORD PTR [rbp-0x8]
    12f4:	64 48 2b 14 25 28 00 	sub    rdx,QWORD PTR fs:0x28
    12fb:	00 00 
    12fd:	74 05                	je     1304 <benchmark_loop_unrolling+0xad>
    12ff:	e8 9c fd ff ff       	call   10a0 <__stack_chk_fail@plt>
    1304:	c9                   	leave
    1305:	c3                   	ret

0000000000001306 <main>:
    1306:	f3 0f 1e fa          	endbr64
    130a:	55                   	push   rbp
    130b:	48 89 e5             	mov    rbp,rsp
    130e:	48 83 ec 40          	sub    rsp,0x40
    1312:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    1319:	00 00 
    131b:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax
    131f:	31 c0                	xor    eax,eax
    1321:	b8 00 00 00 00       	mov    eax,0x0
    1326:	e8 2c ff ff ff       	call   1257 <benchmark_loop_unrolling>
    132b:	48 89 45 c0          	mov    QWORD PTR [rbp-0x40],rax
    132f:	48 8d 45 d0          	lea    rax,[rbp-0x30]
    1333:	48 89 c6             	mov    rsi,rax
    1336:	bf 01 00 00 00       	mov    edi,0x1
    133b:	e8 50 fd ff ff       	call   1090 <clock_gettime@plt>
    1340:	b8 00 00 00 00       	mov    eax,0x0
    1345:	e8 0d ff ff ff       	call   1257 <benchmark_loop_unrolling>
    134a:	48 89 45 c0          	mov    QWORD PTR [rbp-0x40],rax
    134e:	48 8d 45 e0          	lea    rax,[rbp-0x20]
    1352:	48 89 c6             	mov    rsi,rax
    1355:	bf 01 00 00 00       	mov    edi,0x1
    135a:	e8 31 fd ff ff       	call   1090 <clock_gettime@plt>
    135f:	48 8b 55 e0          	mov    rdx,QWORD PTR [rbp-0x20]
    1363:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    1367:	48 29 c2             	sub    rdx,rax
    136a:	66 0f ef c9          	pxor   xmm1,xmm1
    136e:	f2 48 0f 2a ca       	cvtsi2sd xmm1,rdx
    1373:	48 8b 55 e8          	mov    rdx,QWORD PTR [rbp-0x18]
    1377:	48 8b 45 d8          	mov    rax,QWORD PTR [rbp-0x28]
    137b:	48 29 c2             	sub    rdx,rax
    137e:	66 0f ef c0          	pxor   xmm0,xmm0
    1382:	f2 48 0f 2a c2       	cvtsi2sd xmm0,rdx
    1387:	f2 0f 10 15 c1 0c 00 	movsd  xmm2,QWORD PTR [rip+0xcc1]        # 2050 <_IO_stdin_used+0x50>
    138e:	00 
    138f:	f2 0f 5e c2          	divsd  xmm0,xmm2
    1393:	f2 0f 58 c1          	addsd  xmm0,xmm1
    1397:	f2 0f 11 45 c8       	movsd  QWORD PTR [rbp-0x38],xmm0
    139c:	48 8d 05 65 0c 00 00 	lea    rax,[rip+0xc65]        # 2008 <_IO_stdin_used+0x8>
    13a3:	48 89 c7             	mov    rdi,rax
    13a6:	e8 d5 fc ff ff       	call   1080 <puts@plt>
    13ab:	48 8b 45 c0          	mov    rax,QWORD PTR [rbp-0x40]
    13af:	48 89 c6             	mov    rsi,rax
    13b2:	48 8d 05 63 0c 00 00 	lea    rax,[rip+0xc63]        # 201c <_IO_stdin_used+0x1c>
    13b9:	48 89 c7             	mov    rdi,rax
    13bc:	b8 00 00 00 00       	mov    eax,0x0
    13c1:	e8 ea fc ff ff       	call   10b0 <printf@plt>
    13c6:	48 8b 45 c8          	mov    rax,QWORD PTR [rbp-0x38]
    13ca:	66 48 0f 6e c0       	movq   xmm0,rax
    13cf:	48 8d 05 53 0c 00 00 	lea    rax,[rip+0xc53]        # 2029 <_IO_stdin_used+0x29>
    13d6:	48 89 c7             	mov    rdi,rax
    13d9:	b8 01 00 00 00       	mov    eax,0x1
    13de:	e8 cd fc ff ff       	call   10b0 <printf@plt>
    13e3:	be 80 96 98 00       	mov    esi,0x989680
    13e8:	48 8d 05 4e 0c 00 00 	lea    rax,[rip+0xc4e]        # 203d <_IO_stdin_used+0x3d>
    13ef:	48 89 c7             	mov    rdi,rax
    13f2:	b8 00 00 00 00       	mov    eax,0x0
    13f7:	e8 b4 fc ff ff       	call   10b0 <printf@plt>
    13fc:	b8 00 00 00 00       	mov    eax,0x0
    1401:	48 8b 55 f8          	mov    rdx,QWORD PTR [rbp-0x8]
    1405:	64 48 2b 14 25 28 00 	sub    rdx,QWORD PTR fs:0x28
    140c:	00 00 
    140e:	74 05                	je     1415 <main+0x10f>
    1410:	e8 8b fc ff ff       	call   10a0 <__stack_chk_fail@plt>
    1415:	c9                   	leave
    1416:	c3                   	ret

Disassembly of section .fini:

0000000000001418 <_fini>:
    1418:	f3 0f 1e fa          	endbr64
    141c:	48 83 ec 08          	sub    rsp,0x8
    1420:	48 83 c4 08          	add    rsp,0x8
    1424:	c3                   	ret
