
build/01_const_propagation_O0:     file format elf64-x86-64


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
    10d8:	48 8d 3d 71 01 00 00 	lea    rdi,[rip+0x171]        # 1250 <main>
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

00000000000011a9 <compute_with_constants>:
    11a9:	f3 0f 1e fa          	endbr64
    11ad:	55                   	push   rbp
    11ae:	48 89 e5             	mov    rbp,rsp
    11b1:	c7 45 f0 0a 00 00 00 	mov    DWORD PTR [rbp-0x10],0xa
    11b8:	c7 45 f4 14 00 00 00 	mov    DWORD PTR [rbp-0xc],0x14
    11bf:	c7 45 f8 1e 00 00 00 	mov    DWORD PTR [rbp-0x8],0x1e
    11c6:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
    11c9:	0f af 45 f4          	imul   eax,DWORD PTR [rbp-0xc]
    11cd:	8b 55 f8             	mov    edx,DWORD PTR [rbp-0x8]
    11d0:	01 d2                	add    edx,edx
    11d2:	8d 0c 10             	lea    ecx,[rax+rdx*1]
    11d5:	8b 55 f0             	mov    edx,DWORD PTR [rbp-0x10]
    11d8:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    11db:	01 c2                	add    edx,eax
    11dd:	89 c8                	mov    eax,ecx
    11df:	29 d0                	sub    eax,edx
    11e1:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    11e4:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    11e7:	01 c0                	add    eax,eax
    11e9:	83 c0 0f             	add    eax,0xf
    11ec:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    11ef:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    11f2:	48 63 d0             	movsxd rdx,eax
    11f5:	48 69 d2 56 55 55 55 	imul   rdx,rdx,0x55555556
    11fc:	48 89 d1             	mov    rcx,rdx
    11ff:	48 c1 e9 20          	shr    rcx,0x20
    1203:	99                   	cdq
    1204:	89 c8                	mov    eax,ecx
    1206:	29 d0                	sub    eax,edx
    1208:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    120b:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    120e:	5d                   	pop    rbp
    120f:	c3                   	ret

0000000000001210 <benchmark_const_propagation>:
    1210:	f3 0f 1e fa          	endbr64
    1214:	55                   	push   rbp
    1215:	48 89 e5             	mov    rbp,rsp
    1218:	48 83 ec 10          	sub    rsp,0x10
    121c:	48 c7 45 f8 00 00 00 	mov    QWORD PTR [rbp-0x8],0x0
    1223:	00 
    1224:	c7 45 f4 00 00 00 00 	mov    DWORD PTR [rbp-0xc],0x0
    122b:	eb 14                	jmp    1241 <benchmark_const_propagation+0x31>
    122d:	b8 00 00 00 00       	mov    eax,0x0
    1232:	e8 72 ff ff ff       	call   11a9 <compute_with_constants>
    1237:	48 98                	cdqe
    1239:	48 01 45 f8          	add    QWORD PTR [rbp-0x8],rax
    123d:	83 45 f4 01          	add    DWORD PTR [rbp-0xc],0x1
    1241:	81 7d f4 ff e0 f5 05 	cmp    DWORD PTR [rbp-0xc],0x5f5e0ff
    1248:	7e e3                	jle    122d <benchmark_const_propagation+0x1d>
    124a:	48 8b 45 f8          	mov    rax,QWORD PTR [rbp-0x8]
    124e:	c9                   	leave
    124f:	c3                   	ret

0000000000001250 <main>:
    1250:	f3 0f 1e fa          	endbr64
    1254:	55                   	push   rbp
    1255:	48 89 e5             	mov    rbp,rsp
    1258:	48 83 ec 40          	sub    rsp,0x40
    125c:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    1263:	00 00 
    1265:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax
    1269:	31 c0                	xor    eax,eax
    126b:	b8 00 00 00 00       	mov    eax,0x0
    1270:	e8 9b ff ff ff       	call   1210 <benchmark_const_propagation>
    1275:	48 89 45 c0          	mov    QWORD PTR [rbp-0x40],rax
    1279:	48 8d 45 d0          	lea    rax,[rbp-0x30]
    127d:	48 89 c6             	mov    rsi,rax
    1280:	bf 01 00 00 00       	mov    edi,0x1
    1285:	e8 06 fe ff ff       	call   1090 <clock_gettime@plt>
    128a:	b8 00 00 00 00       	mov    eax,0x0
    128f:	e8 7c ff ff ff       	call   1210 <benchmark_const_propagation>
    1294:	48 89 45 c0          	mov    QWORD PTR [rbp-0x40],rax
    1298:	48 8d 45 e0          	lea    rax,[rbp-0x20]
    129c:	48 89 c6             	mov    rsi,rax
    129f:	bf 01 00 00 00       	mov    edi,0x1
    12a4:	e8 e7 fd ff ff       	call   1090 <clock_gettime@plt>
    12a9:	48 8b 55 e0          	mov    rdx,QWORD PTR [rbp-0x20]
    12ad:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    12b1:	48 29 c2             	sub    rdx,rax
    12b4:	66 0f ef c9          	pxor   xmm1,xmm1
    12b8:	f2 48 0f 2a ca       	cvtsi2sd xmm1,rdx
    12bd:	48 8b 55 e8          	mov    rdx,QWORD PTR [rbp-0x18]
    12c1:	48 8b 45 d8          	mov    rax,QWORD PTR [rbp-0x28]
    12c5:	48 29 c2             	sub    rdx,rax
    12c8:	66 0f ef c0          	pxor   xmm0,xmm0
    12cc:	f2 48 0f 2a c2       	cvtsi2sd xmm0,rdx
    12d1:	f2 0f 10 15 7f 0d 00 	movsd  xmm2,QWORD PTR [rip+0xd7f]        # 2058 <_IO_stdin_used+0x58>
    12d8:	00 
    12d9:	f2 0f 5e c2          	divsd  xmm0,xmm2
    12dd:	f2 0f 58 c1          	addsd  xmm0,xmm1
    12e1:	f2 0f 11 45 c8       	movsd  QWORD PTR [rbp-0x38],xmm0
    12e6:	48 8d 05 1b 0d 00 00 	lea    rax,[rip+0xd1b]        # 2008 <_IO_stdin_used+0x8>
    12ed:	48 89 c7             	mov    rdi,rax
    12f0:	e8 8b fd ff ff       	call   1080 <puts@plt>
    12f5:	48 8b 45 c0          	mov    rax,QWORD PTR [rbp-0x40]
    12f9:	48 89 c6             	mov    rsi,rax
    12fc:	48 8d 05 1f 0d 00 00 	lea    rax,[rip+0xd1f]        # 2022 <_IO_stdin_used+0x22>
    1303:	48 89 c7             	mov    rdi,rax
    1306:	b8 00 00 00 00       	mov    eax,0x0
    130b:	e8 a0 fd ff ff       	call   10b0 <printf@plt>
    1310:	48 8b 45 c8          	mov    rax,QWORD PTR [rbp-0x38]
    1314:	66 48 0f 6e c0       	movq   xmm0,rax
    1319:	48 8d 05 0f 0d 00 00 	lea    rax,[rip+0xd0f]        # 202f <_IO_stdin_used+0x2f>
    1320:	48 89 c7             	mov    rdi,rax
    1323:	b8 01 00 00 00       	mov    eax,0x1
    1328:	e8 83 fd ff ff       	call   10b0 <printf@plt>
    132d:	be 00 e1 f5 05       	mov    esi,0x5f5e100
    1332:	48 8d 05 0a 0d 00 00 	lea    rax,[rip+0xd0a]        # 2043 <_IO_stdin_used+0x43>
    1339:	48 89 c7             	mov    rdi,rax
    133c:	b8 00 00 00 00       	mov    eax,0x0
    1341:	e8 6a fd ff ff       	call   10b0 <printf@plt>
    1346:	b8 00 00 00 00       	mov    eax,0x0
    134b:	48 8b 55 f8          	mov    rdx,QWORD PTR [rbp-0x8]
    134f:	64 48 2b 14 25 28 00 	sub    rdx,QWORD PTR fs:0x28
    1356:	00 00 
    1358:	74 05                	je     135f <main+0x10f>
    135a:	e8 41 fd ff ff       	call   10a0 <__stack_chk_fail@plt>
    135f:	c9                   	leave
    1360:	c3                   	ret

Disassembly of section .fini:

0000000000001364 <_fini>:
    1364:	f3 0f 1e fa          	endbr64
    1368:	48 83 ec 08          	sub    rsp,0x8
    136c:	48 83 c4 08          	add    rsp,0x8
    1370:	c3                   	ret
