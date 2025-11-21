
build/02_loop_unrolling_O1:     file format elf64-x86-64


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
    10d8:	48 8d 3d b1 01 00 00 	lea    rdi,[rip+0x1b1]        # 1290 <main>
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
    11ad:	48 8d 4f 20          	lea    rcx,[rdi+0x20]
    11b1:	ba 00 00 00 00       	mov    edx,0x0
    11b6:	89 d0                	mov    eax,edx
    11b8:	03 07                	add    eax,DWORD PTR [rdi]
    11ba:	89 c2                	mov    edx,eax
    11bc:	48 83 c7 04          	add    rdi,0x4
    11c0:	48 39 cf             	cmp    rdi,rcx
    11c3:	75 f1                	jne    11b6 <sum_small_array+0xd>
    11c5:	c3                   	ret

00000000000011c6 <process_array>:
    11c6:	f3 0f 1e fa          	endbr64
    11ca:	48 8d 77 20          	lea    rsi,[rdi+0x20]
    11ce:	b8 00 00 00 00       	mov    eax,0x0
    11d3:	8b 0f                	mov    ecx,DWORD PTR [rdi]
    11d5:	8d 04 48             	lea    eax,[rax+rcx*2]
    11d8:	89 ca                	mov    edx,ecx
    11da:	c1 ea 1f             	shr    edx,0x1f
    11dd:	01 ca                	add    edx,ecx
    11df:	d1 fa                	sar    edx,1
    11e1:	29 d0                	sub    eax,edx
    11e3:	48 83 c7 04          	add    rdi,0x4
    11e7:	48 39 f7             	cmp    rdi,rsi
    11ea:	75 e7                	jne    11d3 <process_array+0xd>
    11ec:	c3                   	ret

00000000000011ed <benchmark_loop_unrolling>:
    11ed:	f3 0f 1e fa          	endbr64
    11f1:	55                   	push   rbp
    11f2:	53                   	push   rbx
    11f3:	48 83 ec 38          	sub    rsp,0x38
    11f7:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    11fe:	00 00 
    1200:	48 89 44 24 28       	mov    QWORD PTR [rsp+0x28],rax
    1205:	31 c0                	xor    eax,eax
    1207:	c7 04 24 01 00 00 00 	mov    DWORD PTR [rsp],0x1
    120e:	c7 44 24 04 02 00 00 	mov    DWORD PTR [rsp+0x4],0x2
    1215:	00 
    1216:	c7 44 24 08 03 00 00 	mov    DWORD PTR [rsp+0x8],0x3
    121d:	00 
    121e:	c7 44 24 0c 04 00 00 	mov    DWORD PTR [rsp+0xc],0x4
    1225:	00 
    1226:	c7 44 24 10 05 00 00 	mov    DWORD PTR [rsp+0x10],0x5
    122d:	00 
    122e:	c7 44 24 14 06 00 00 	mov    DWORD PTR [rsp+0x14],0x6
    1235:	00 
    1236:	c7 44 24 18 07 00 00 	mov    DWORD PTR [rsp+0x18],0x7
    123d:	00 
    123e:	c7 44 24 1c 08 00 00 	mov    DWORD PTR [rsp+0x1c],0x8
    1245:	00 
    1246:	48 89 e5             	mov    rbp,rsp
    1249:	48 89 ef             	mov    rdi,rbp
    124c:	e8 58 ff ff ff       	call   11a9 <sum_small_array>
    1251:	48 63 d8             	movsxd rbx,eax
    1254:	48 89 ef             	mov    rdi,rbp
    1257:	e8 6a ff ff ff       	call   11c6 <process_array>
    125c:	48 63 d0             	movsxd rdx,eax
    125f:	b8 80 96 98 00       	mov    eax,0x989680
    1264:	83 e8 01             	sub    eax,0x1
    1267:	75 fb                	jne    1264 <benchmark_loop_unrolling+0x77>
    1269:	48 8d 04 13          	lea    rax,[rbx+rdx*1]
    126d:	48 69 c0 80 96 98 00 	imul   rax,rax,0x989680
    1274:	48 8b 54 24 28       	mov    rdx,QWORD PTR [rsp+0x28]
    1279:	64 48 2b 14 25 28 00 	sub    rdx,QWORD PTR fs:0x28
    1280:	00 00 
    1282:	75 07                	jne    128b <benchmark_loop_unrolling+0x9e>
    1284:	48 83 c4 38          	add    rsp,0x38
    1288:	5b                   	pop    rbx
    1289:	5d                   	pop    rbp
    128a:	c3                   	ret
    128b:	e8 10 fe ff ff       	call   10a0 <__stack_chk_fail@plt>

0000000000001290 <main>:
    1290:	f3 0f 1e fa          	endbr64
    1294:	53                   	push   rbx
    1295:	48 83 ec 50          	sub    rsp,0x50
    1299:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    12a0:	00 00 
    12a2:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
    12a7:	31 c0                	xor    eax,eax
    12a9:	e8 3f ff ff ff       	call   11ed <benchmark_loop_unrolling>
    12ae:	48 89 c3             	mov    rbx,rax
    12b1:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    12b6:	48 8d 74 24 20       	lea    rsi,[rsp+0x20]
    12bb:	bf 01 00 00 00       	mov    edi,0x1
    12c0:	e8 cb fd ff ff       	call   1090 <clock_gettime@plt>
    12c5:	48 89 5c 24 18       	mov    QWORD PTR [rsp+0x18],rbx
    12ca:	48 8d 74 24 30       	lea    rsi,[rsp+0x30]
    12cf:	bf 01 00 00 00       	mov    edi,0x1
    12d4:	e8 b7 fd ff ff       	call   1090 <clock_gettime@plt>
    12d9:	48 8b 44 24 38       	mov    rax,QWORD PTR [rsp+0x38]
    12de:	48 2b 44 24 28       	sub    rax,QWORD PTR [rsp+0x28]
    12e3:	66 0f ef c0          	pxor   xmm0,xmm0
    12e7:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    12ec:	f2 0f 5e 05 5c 0d 00 	divsd  xmm0,QWORD PTR [rip+0xd5c]        # 2050 <_IO_stdin_used+0x50>
    12f3:	00 
    12f4:	48 8b 44 24 30       	mov    rax,QWORD PTR [rsp+0x30]
    12f9:	48 2b 44 24 20       	sub    rax,QWORD PTR [rsp+0x20]
    12fe:	66 0f ef c9          	pxor   xmm1,xmm1
    1302:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    1307:	f2 0f 58 c1          	addsd  xmm0,xmm1
    130b:	f2 0f 11 44 24 08    	movsd  QWORD PTR [rsp+0x8],xmm0
    1311:	48 8d 3d ec 0c 00 00 	lea    rdi,[rip+0xcec]        # 2004 <_IO_stdin_used+0x4>
    1318:	e8 63 fd ff ff       	call   1080 <puts@plt>
    131d:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
    1322:	48 8d 35 ef 0c 00 00 	lea    rsi,[rip+0xcef]        # 2018 <_IO_stdin_used+0x18>
    1329:	bf 02 00 00 00       	mov    edi,0x2
    132e:	b8 00 00 00 00       	mov    eax,0x0
    1333:	e8 78 fd ff ff       	call   10b0 <__printf_chk@plt>
    1338:	f2 0f 10 44 24 08    	movsd  xmm0,QWORD PTR [rsp+0x8]
    133e:	48 8d 35 e0 0c 00 00 	lea    rsi,[rip+0xce0]        # 2025 <_IO_stdin_used+0x25>
    1345:	bf 02 00 00 00       	mov    edi,0x2
    134a:	b8 01 00 00 00       	mov    eax,0x1
    134f:	e8 5c fd ff ff       	call   10b0 <__printf_chk@plt>
    1354:	ba 80 96 98 00       	mov    edx,0x989680
    1359:	48 8d 35 d9 0c 00 00 	lea    rsi,[rip+0xcd9]        # 2039 <_IO_stdin_used+0x39>
    1360:	bf 02 00 00 00       	mov    edi,0x2
    1365:	b8 00 00 00 00       	mov    eax,0x0
    136a:	e8 41 fd ff ff       	call   10b0 <__printf_chk@plt>
    136f:	48 8b 44 24 48       	mov    rax,QWORD PTR [rsp+0x48]
    1374:	64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
    137b:	00 00 
    137d:	75 0b                	jne    138a <main+0xfa>
    137f:	b8 00 00 00 00       	mov    eax,0x0
    1384:	48 83 c4 50          	add    rsp,0x50
    1388:	5b                   	pop    rbx
    1389:	c3                   	ret
    138a:	e8 11 fd ff ff       	call   10a0 <__stack_chk_fail@plt>

Disassembly of section .fini:

0000000000001390 <_fini>:
    1390:	f3 0f 1e fa          	endbr64
    1394:	48 83 ec 08          	sub    rsp,0x8
    1398:	48 83 c4 08          	add    rsp,0x8
    139c:	c3                   	ret
