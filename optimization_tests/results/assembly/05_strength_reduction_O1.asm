
build/05_strength_reduction_O1:     file format elf64-x86-64


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
    10d8:	48 8d 3d 70 01 00 00 	lea    rdi,[rip+0x170]        # 124f <main>
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
    11ad:	89 f8                	mov    eax,edi
    11af:	8d 14 bd 00 00 00 00 	lea    edx,[rdi*4+0x0]
    11b6:	8d 14 7a             	lea    edx,[rdx+rdi*2]
    11b9:	8d 0c fa             	lea    ecx,[rdx+rdi*8]
    11bc:	89 fa                	mov    edx,edi
    11be:	c1 e2 04             	shl    edx,0x4
    11c1:	01 ca                	add    edx,ecx
    11c3:	89 f9                	mov    ecx,edi
    11c5:	c1 e9 1f             	shr    ecx,0x1f
    11c8:	01 f9                	add    ecx,edi
    11ca:	d1 f9                	sar    ecx,1
    11cc:	01 d1                	add    ecx,edx
    11ce:	8d 57 03             	lea    edx,[rdi+0x3]
    11d1:	85 ff                	test   edi,edi
    11d3:	0f 49 d7             	cmovns edx,edi
    11d6:	c1 fa 02             	sar    edx,0x2
    11d9:	01 ca                	add    edx,ecx
    11db:	89 f9                	mov    ecx,edi
    11dd:	c1 f9 1f             	sar    ecx,0x1f
    11e0:	c1 e9 1d             	shr    ecx,0x1d
    11e3:	01 c8                	add    eax,ecx
    11e5:	83 e0 07             	and    eax,0x7
    11e8:	29 c8                	sub    eax,ecx
    11ea:	8d 84 02 87 00 00 00 	lea    eax,[rdx+rax*1+0x87]
    11f1:	c3                   	ret

00000000000011f2 <compute_optimized>:
    11f2:	f3 0f 1e fa          	endbr64
    11f6:	8d 14 7f             	lea    edx,[rdi+rdi*2]
    11f9:	8d 04 fd 00 00 00 00 	lea    eax,[rdi*8+0x0]
    1200:	8d 14 50             	lea    edx,[rax+rdx*2]
    1203:	89 f8                	mov    eax,edi
    1205:	c1 e0 04             	shl    eax,0x4
    1208:	01 d0                	add    eax,edx
    120a:	89 fa                	mov    edx,edi
    120c:	d1 fa                	sar    edx,1
    120e:	01 c2                	add    edx,eax
    1210:	89 f8                	mov    eax,edi
    1212:	c1 f8 02             	sar    eax,0x2
    1215:	01 d0                	add    eax,edx
    1217:	83 e7 07             	and    edi,0x7
    121a:	8d 84 38 87 00 00 00 	lea    eax,[rax+rdi*1+0x87]
    1221:	c3                   	ret

0000000000001222 <benchmark_strength_reduction>:
    1222:	f3 0f 1e fa          	endbr64
    1226:	55                   	push   rbp
    1227:	53                   	push   rbx
    1228:	bb 00 00 00 00       	mov    ebx,0x0
    122d:	bd 00 00 00 00       	mov    ebp,0x0
    1232:	89 df                	mov    edi,ebx
    1234:	e8 70 ff ff ff       	call   11a9 <compute_with_expensive_ops>
    1239:	48 98                	cdqe
    123b:	48 01 c5             	add    rbp,rax
    123e:	83 c3 01             	add    ebx,0x1
    1241:	81 fb 00 e1 f5 05    	cmp    ebx,0x5f5e100
    1247:	75 e9                	jne    1232 <benchmark_strength_reduction+0x10>
    1249:	48 89 e8             	mov    rax,rbp
    124c:	5b                   	pop    rbx
    124d:	5d                   	pop    rbp
    124e:	c3                   	ret

000000000000124f <main>:
    124f:	f3 0f 1e fa          	endbr64
    1253:	53                   	push   rbx
    1254:	48 83 ec 50          	sub    rsp,0x50
    1258:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    125f:	00 00 
    1261:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
    1266:	31 c0                	xor    eax,eax
    1268:	e8 b5 ff ff ff       	call   1222 <benchmark_strength_reduction>
    126d:	48 89 c3             	mov    rbx,rax
    1270:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    1275:	48 8d 74 24 20       	lea    rsi,[rsp+0x20]
    127a:	bf 01 00 00 00       	mov    edi,0x1
    127f:	e8 0c fe ff ff       	call   1090 <clock_gettime@plt>
    1284:	48 89 5c 24 18       	mov    QWORD PTR [rsp+0x18],rbx
    1289:	48 8d 74 24 30       	lea    rsi,[rsp+0x30]
    128e:	bf 01 00 00 00       	mov    edi,0x1
    1293:	e8 f8 fd ff ff       	call   1090 <clock_gettime@plt>
    1298:	48 8b 44 24 38       	mov    rax,QWORD PTR [rsp+0x38]
    129d:	48 2b 44 24 28       	sub    rax,QWORD PTR [rsp+0x28]
    12a2:	66 0f ef c0          	pxor   xmm0,xmm0
    12a6:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    12ab:	f2 0f 5e 05 9d 0d 00 	divsd  xmm0,QWORD PTR [rip+0xd9d]        # 2050 <_IO_stdin_used+0x50>
    12b2:	00 
    12b3:	48 8b 44 24 30       	mov    rax,QWORD PTR [rsp+0x30]
    12b8:	48 2b 44 24 20       	sub    rax,QWORD PTR [rsp+0x20]
    12bd:	66 0f ef c9          	pxor   xmm1,xmm1
    12c1:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    12c6:	f2 0f 58 c1          	addsd  xmm0,xmm1
    12ca:	f2 0f 11 44 24 08    	movsd  QWORD PTR [rsp+0x8],xmm0
    12d0:	48 8d 3d 2d 0d 00 00 	lea    rdi,[rip+0xd2d]        # 2004 <_IO_stdin_used+0x4>
    12d7:	e8 a4 fd ff ff       	call   1080 <puts@plt>
    12dc:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
    12e1:	48 8d 35 34 0d 00 00 	lea    rsi,[rip+0xd34]        # 201c <_IO_stdin_used+0x1c>
    12e8:	bf 02 00 00 00       	mov    edi,0x2
    12ed:	b8 00 00 00 00       	mov    eax,0x0
    12f2:	e8 b9 fd ff ff       	call   10b0 <__printf_chk@plt>
    12f7:	f2 0f 10 44 24 08    	movsd  xmm0,QWORD PTR [rsp+0x8]
    12fd:	48 8d 35 25 0d 00 00 	lea    rsi,[rip+0xd25]        # 2029 <_IO_stdin_used+0x29>
    1304:	bf 02 00 00 00       	mov    edi,0x2
    1309:	b8 01 00 00 00       	mov    eax,0x1
    130e:	e8 9d fd ff ff       	call   10b0 <__printf_chk@plt>
    1313:	ba 00 e1 f5 05       	mov    edx,0x5f5e100
    1318:	48 8d 35 1e 0d 00 00 	lea    rsi,[rip+0xd1e]        # 203d <_IO_stdin_used+0x3d>
    131f:	bf 02 00 00 00       	mov    edi,0x2
    1324:	b8 00 00 00 00       	mov    eax,0x0
    1329:	e8 82 fd ff ff       	call   10b0 <__printf_chk@plt>
    132e:	48 8b 44 24 48       	mov    rax,QWORD PTR [rsp+0x48]
    1333:	64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
    133a:	00 00 
    133c:	75 0b                	jne    1349 <main+0xfa>
    133e:	b8 00 00 00 00       	mov    eax,0x0
    1343:	48 83 c4 50          	add    rsp,0x50
    1347:	5b                   	pop    rbx
    1348:	c3                   	ret
    1349:	e8 52 fd ff ff       	call   10a0 <__stack_chk_fail@plt>

Disassembly of section .fini:

0000000000001350 <_fini>:
    1350:	f3 0f 1e fa          	endbr64
    1354:	48 83 ec 08          	sub    rsp,0x8
    1358:	48 83 c4 08          	add    rsp,0x8
    135c:	c3                   	ret
