
build/06_cse_O1:     file format elf64-x86-64


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
    10d8:	48 8d 3d d7 01 00 00 	lea    rdi,[rip+0x1d7]        # 12b6 <main>
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

00000000000011a9 <compute_with_redundancy>:
    11a9:	f3 0f 1e fa          	endbr64
    11ad:	8d 04 37             	lea    eax,[rdi+rsi*1]
    11b0:	8d 14 00             	lea    edx,[rax+rax*1]
    11b3:	8d 0c 02             	lea    ecx,[rdx+rax*1]
    11b6:	8d 04 76             	lea    eax,[rsi+rsi*2]
    11b9:	8d 34 78             	lea    esi,[rax+rdi*2]
    11bc:	8d 04 b5 00 00 00 00 	lea    eax,[rsi*4+0x0]
    11c3:	01 c2                	add    edx,eax
    11c5:	01 f0                	add    eax,esi
    11c7:	01 c8                	add    eax,ecx
    11c9:	01 c2                	add    edx,eax
    11cb:	89 d0                	mov    eax,edx
    11cd:	c1 e8 1f             	shr    eax,0x1f
    11d0:	01 d0                	add    eax,edx
    11d2:	d1 f8                	sar    eax,1
    11d4:	01 d0                	add    eax,edx
    11d6:	48 63 ca             	movsxd rcx,edx
    11d9:	48 69 c9 56 55 55 55 	imul   rcx,rcx,0x55555556
    11e0:	48 c1 e9 20          	shr    rcx,0x20
    11e4:	c1 fa 1f             	sar    edx,0x1f
    11e7:	29 d1                	sub    ecx,edx
    11e9:	01 c8                	add    eax,ecx
    11eb:	c3                   	ret

00000000000011ec <compute_optimized>:
    11ec:	f3 0f 1e fa          	endbr64
    11f0:	8d 04 37             	lea    eax,[rdi+rsi*1]
    11f3:	8d 14 76             	lea    edx,[rsi+rsi*2]
    11f6:	8d 34 7a             	lea    esi,[rdx+rdi*2]
    11f9:	8d 14 00             	lea    edx,[rax+rax*1]
    11fc:	8d 0c 02             	lea    ecx,[rdx+rax*1]
    11ff:	8d 04 b5 00 00 00 00 	lea    eax,[rsi*4+0x0]
    1206:	01 c2                	add    edx,eax
    1208:	01 f0                	add    eax,esi
    120a:	01 c8                	add    eax,ecx
    120c:	01 c2                	add    edx,eax
    120e:	89 d0                	mov    eax,edx
    1210:	c1 e8 1f             	shr    eax,0x1f
    1213:	01 d0                	add    eax,edx
    1215:	d1 f8                	sar    eax,1
    1217:	01 d0                	add    eax,edx
    1219:	48 63 ca             	movsxd rcx,edx
    121c:	48 69 c9 56 55 55 55 	imul   rcx,rcx,0x55555556
    1223:	48 c1 e9 20          	shr    rcx,0x20
    1227:	c1 fa 1f             	sar    edx,0x1f
    122a:	29 d1                	sub    ecx,edx
    122c:	01 c8                	add    eax,ecx
    122e:	c3                   	ret

000000000000122f <complex_computation>:
    122f:	f3 0f 1e fa          	endbr64
    1233:	89 f9                	mov    ecx,edi
    1235:	89 f7                	mov    edi,esi
    1237:	89 c8                	mov    eax,ecx
    1239:	0f af c1             	imul   eax,ecx
    123c:	0f af f6             	imul   esi,esi
    123f:	01 f0                	add    eax,esi
    1241:	48 63 f0             	movsxd rsi,eax
    1244:	48 69 f6 56 55 55 55 	imul   rsi,rsi,0x55555556
    124b:	48 c1 ee 20          	shr    rsi,0x20
    124f:	41 89 c0             	mov    r8d,eax
    1252:	41 c1 f8 1f          	sar    r8d,0x1f
    1256:	44 29 c6             	sub    esi,r8d
    1259:	8d 34 46             	lea    esi,[rsi+rax*2]
    125c:	29 d0                	sub    eax,edx
    125e:	01 c6                	add    esi,eax
    1260:	01 f9                	add    ecx,edi
    1262:	8d 04 11             	lea    eax,[rcx+rdx*1]
    1265:	0f af c0             	imul   eax,eax
    1268:	01 f0                	add    eax,esi
    126a:	c3                   	ret

000000000000126b <benchmark_cse>:
    126b:	f3 0f 1e fa          	endbr64
    126f:	41 54                	push   r12
    1271:	55                   	push   rbp
    1272:	53                   	push   rbx
    1273:	bb 00 00 00 00       	mov    ebx,0x0
    1278:	bd 00 00 00 00       	mov    ebp,0x0
    127d:	41 89 dc             	mov    r12d,ebx
    1280:	83 c3 01             	add    ebx,0x1
    1283:	89 de                	mov    esi,ebx
    1285:	44 89 e7             	mov    edi,r12d
    1288:	e8 1c ff ff ff       	call   11a9 <compute_with_redundancy>
    128d:	48 98                	cdqe
    128f:	48 01 c5             	add    rbp,rax
    1292:	41 8d 54 24 02       	lea    edx,[r12+0x2]
    1297:	89 de                	mov    esi,ebx
    1299:	44 89 e7             	mov    edi,r12d
    129c:	e8 8e ff ff ff       	call   122f <complex_computation>
    12a1:	48 98                	cdqe
    12a3:	48 01 c5             	add    rbp,rax
    12a6:	81 fb 80 f0 fa 02    	cmp    ebx,0x2faf080
    12ac:	75 cf                	jne    127d <benchmark_cse+0x12>
    12ae:	48 89 e8             	mov    rax,rbp
    12b1:	5b                   	pop    rbx
    12b2:	5d                   	pop    rbp
    12b3:	41 5c                	pop    r12
    12b5:	c3                   	ret

00000000000012b6 <main>:
    12b6:	f3 0f 1e fa          	endbr64
    12ba:	53                   	push   rbx
    12bb:	48 83 ec 50          	sub    rsp,0x50
    12bf:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    12c6:	00 00 
    12c8:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
    12cd:	31 c0                	xor    eax,eax
    12cf:	e8 97 ff ff ff       	call   126b <benchmark_cse>
    12d4:	48 89 c3             	mov    rbx,rax
    12d7:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    12dc:	48 8d 74 24 20       	lea    rsi,[rsp+0x20]
    12e1:	bf 01 00 00 00       	mov    edi,0x1
    12e6:	e8 a5 fd ff ff       	call   1090 <clock_gettime@plt>
    12eb:	48 89 5c 24 18       	mov    QWORD PTR [rsp+0x18],rbx
    12f0:	48 8d 74 24 30       	lea    rsi,[rsp+0x30]
    12f5:	bf 01 00 00 00       	mov    edi,0x1
    12fa:	e8 91 fd ff ff       	call   1090 <clock_gettime@plt>
    12ff:	48 8b 44 24 38       	mov    rax,QWORD PTR [rsp+0x38]
    1304:	48 2b 44 24 28       	sub    rax,QWORD PTR [rsp+0x28]
    1309:	66 0f ef c0          	pxor   xmm0,xmm0
    130d:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    1312:	f2 0f 5e 05 46 0d 00 	divsd  xmm0,QWORD PTR [rip+0xd46]        # 2060 <_IO_stdin_used+0x60>
    1319:	00 
    131a:	48 8b 44 24 30       	mov    rax,QWORD PTR [rsp+0x30]
    131f:	48 2b 44 24 20       	sub    rax,QWORD PTR [rsp+0x20]
    1324:	66 0f ef c9          	pxor   xmm1,xmm1
    1328:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    132d:	f2 0f 58 c1          	addsd  xmm0,xmm1
    1331:	f2 0f 11 44 24 08    	movsd  QWORD PTR [rsp+0x8],xmm0
    1337:	48 8d 3d ca 0c 00 00 	lea    rdi,[rip+0xcca]        # 2008 <_IO_stdin_used+0x8>
    133e:	e8 3d fd ff ff       	call   1080 <puts@plt>
    1343:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
    1348:	48 8d 35 df 0c 00 00 	lea    rsi,[rip+0xcdf]        # 202e <_IO_stdin_used+0x2e>
    134f:	bf 02 00 00 00       	mov    edi,0x2
    1354:	b8 00 00 00 00       	mov    eax,0x0
    1359:	e8 52 fd ff ff       	call   10b0 <__printf_chk@plt>
    135e:	f2 0f 10 44 24 08    	movsd  xmm0,QWORD PTR [rsp+0x8]
    1364:	48 8d 35 d0 0c 00 00 	lea    rsi,[rip+0xcd0]        # 203b <_IO_stdin_used+0x3b>
    136b:	bf 02 00 00 00       	mov    edi,0x2
    1370:	b8 01 00 00 00       	mov    eax,0x1
    1375:	e8 36 fd ff ff       	call   10b0 <__printf_chk@plt>
    137a:	ba 80 f0 fa 02       	mov    edx,0x2faf080
    137f:	48 8d 35 c9 0c 00 00 	lea    rsi,[rip+0xcc9]        # 204f <_IO_stdin_used+0x4f>
    1386:	bf 02 00 00 00       	mov    edi,0x2
    138b:	b8 00 00 00 00       	mov    eax,0x0
    1390:	e8 1b fd ff ff       	call   10b0 <__printf_chk@plt>
    1395:	48 8b 44 24 48       	mov    rax,QWORD PTR [rsp+0x48]
    139a:	64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
    13a1:	00 00 
    13a3:	75 0b                	jne    13b0 <main+0xfa>
    13a5:	b8 00 00 00 00       	mov    eax,0x0
    13aa:	48 83 c4 50          	add    rsp,0x50
    13ae:	5b                   	pop    rbx
    13af:	c3                   	ret
    13b0:	e8 eb fc ff ff       	call   10a0 <__stack_chk_fail@plt>

Disassembly of section .fini:

00000000000013b8 <_fini>:
    13b8:	f3 0f 1e fa          	endbr64
    13bc:	48 83 ec 08          	sub    rsp,0x8
    13c0:	48 83 c4 08          	add    rsp,0x8
    13c4:	c3                   	ret
