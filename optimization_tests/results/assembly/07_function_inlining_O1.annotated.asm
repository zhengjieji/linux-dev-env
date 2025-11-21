
build/07_function_inlining_O1:     file format elf64-x86-64


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
    10d8:	48 8d 3d 6e 01 00 00 	lea    rdi,[rip+0x16e]        # 124d <main>
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

00000000000011a9 <compute_with_calls>:
    11a9:	f3 0f 1e fa          	endbr64
    11ad:	89 f8                	mov    eax,edi
    11af:	0f af c7             	imul   eax,edi
    11b2:	8d 44 b8 0a          	lea    eax,[rax+rdi*4+0xa]
    11b6:	c3                   	ret

00000000000011b7 <larger_function>:
    11b7:	f3 0f 1e fa          	endbr64
    11bb:	41 b9 00 00 00 00    	mov    r9d,0x0
    11c1:	b9 00 00 00 00       	mov    ecx,0x0
    11c6:	41 b8 00 00 00 00    	mov    r8d,0x0
    11cc:	45 01 c8             	add    r8d,r9d
    11cf:	83 c1 01             	add    ecx,0x1
    11d2:	89 f0                	mov    eax,esi
    11d4:	99                   	cdq
    11d5:	f7 f9                	idiv   ecx
    11d7:	41 29 c0             	sub    r8d,eax
    11da:	41 01 f9             	add    r9d,edi
    11dd:	83 f9 05             	cmp    ecx,0x5
    11e0:	75 ea                	jne    11cc <larger_function+0x15>
    11e2:	44 89 c0             	mov    eax,r8d
    11e5:	c3                   	ret

00000000000011e6 <compute_with_larger_call>:
    11e6:	f3 0f 1e fa          	endbr64
    11ea:	8d 77 01             	lea    esi,[rdi+0x1]
    11ed:	e8 c5 ff ff ff       	call   11b7 <larger_function>
    11f2:	c3                   	ret

00000000000011f3 <benchmark_inlining>:
    11f3:	f3 0f 1e fa          	endbr64
    11f7:	55                   	push   rbp
    11f8:	53                   	push   rbx
    11f9:	bb 00 00 00 00       	mov    ebx,0x0
    11fe:	bd 00 00 00 00       	mov    ebp,0x0
    1203:	89 df                	mov    edi,ebx
    1205:	e8 9f ff ff ff       	call   11a9 <compute_with_calls>
    120a:	48 98                	cdqe
    120c:	48 01 c5             	add    rbp,rax
    120f:	83 c3 01             	add    ebx,0x1
    1212:	81 fb 00 e1 f5 05    	cmp    ebx,0x5f5e100
    1218:	75 e9                	jne    1203 <benchmark_inlining+0x10>
    121a:	48 89 e8             	mov    rax,rbp
    121d:	5b                   	pop    rbx
    121e:	5d                   	pop    rbp
    121f:	c3                   	ret

0000000000001220 <benchmark_larger_calls>:
    1220:	f3 0f 1e fa          	endbr64
    1224:	55                   	push   rbp
    1225:	53                   	push   rbx
    1226:	bb 00 00 00 00       	mov    ebx,0x0
    122b:	bd 00 00 00 00       	mov    ebp,0x0
    1230:	89 df                	mov    edi,ebx
    1232:	e8 af ff ff ff       	call   11e6 <compute_with_larger_call>
    1237:	48 98                	cdqe
    1239:	48 01 c5             	add    rbp,rax
    123c:	83 c3 01             	add    ebx,0x1
    123f:	81 fb 80 96 98 00    	cmp    ebx,0x989680
    1245:	75 e9                	jne    1230 <benchmark_larger_calls+0x10>
    1247:	48 89 e8             	mov    rax,rbp
    124a:	5b                   	pop    rbx
    124b:	5d                   	pop    rbp
    124c:	c3                   	ret

000000000000124d <main>:
    124d:	f3 0f 1e fa          	endbr64
    1251:	55                   	push   rbp
    1252:	53                   	push   rbx
    1253:	48 83 ec 58          	sub    rsp,0x58
    1257:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    125e:	00 00 
    1260:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
    1265:	31 c0                	xor    eax,eax
    1267:	e8 87 ff ff ff       	call   11f3 <benchmark_inlining>
    126c:	48 89 c3             	mov    rbx,rax
    126f:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    1274:	48 8d 6c 24 20       	lea    rbp,[rsp+0x20]
    1279:	48 89 ee             	mov    rsi,rbp
    127c:	bf 01 00 00 00       	mov    edi,0x1
    1281:	e8 0a fe ff ff       	call   1090 <clock_gettime@plt>
    1286:	48 89 5c 24 18       	mov    QWORD PTR [rsp+0x18],rbx
    128b:	48 8d 5c 24 30       	lea    rbx,[rsp+0x30]
    1290:	48 89 de             	mov    rsi,rbx
    1293:	bf 01 00 00 00       	mov    edi,0x1
    1298:	e8 f3 fd ff ff       	call   1090 <clock_gettime@plt>
    129d:	48 8b 44 24 38       	mov    rax,QWORD PTR [rsp+0x38]
    12a2:	48 2b 44 24 28       	sub    rax,QWORD PTR [rsp+0x28]
    12a7:	66 0f ef c0          	pxor   xmm0,xmm0
    12ab:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    12b0:	f2 0f 5e 05 e0 0d 00 	divsd  xmm0,QWORD PTR [rip+0xde0]        # 2098 <_IO_stdin_used+0x98>
    12b7:	00 
    12b8:	48 8b 44 24 30       	mov    rax,QWORD PTR [rsp+0x30]
    12bd:	48 2b 44 24 20       	sub    rax,QWORD PTR [rsp+0x20]
    12c2:	66 0f ef c9          	pxor   xmm1,xmm1
    12c6:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    12cb:	f2 0f 58 c1          	addsd  xmm0,xmm1
    12cf:	f2 0f 11 04 24       	movsd  QWORD PTR [rsp],xmm0
    12d4:	48 89 ee             	mov    rsi,rbp
    12d7:	bf 01 00 00 00       	mov    edi,0x1
    12dc:	e8 af fd ff ff       	call   1090 <clock_gettime@plt>
    12e1:	b8 00 00 00 00       	mov    eax,0x0
    12e6:	e8 35 ff ff ff       	call   1220 <benchmark_larger_calls>
    12eb:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    12f0:	48 89 de             	mov    rsi,rbx
    12f3:	bf 01 00 00 00       	mov    edi,0x1
    12f8:	e8 93 fd ff ff       	call   1090 <clock_gettime@plt>
    12fd:	48 8b 44 24 38       	mov    rax,QWORD PTR [rsp+0x38]
    1302:	48 2b 44 24 28       	sub    rax,QWORD PTR [rsp+0x28]
    1307:	66 0f ef c0          	pxor   xmm0,xmm0
    130b:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    1310:	f2 0f 5e 05 80 0d 00 	divsd  xmm0,QWORD PTR [rip+0xd80]        # 2098 <_IO_stdin_used+0x98>
    1317:	00 
    1318:	48 8b 44 24 30       	mov    rax,QWORD PTR [rsp+0x30]
    131d:	48 2b 44 24 20       	sub    rax,QWORD PTR [rsp+0x20]
    1322:	66 0f ef c9          	pxor   xmm1,xmm1
    1326:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    132b:	66 0f 28 d0          	movapd xmm2,xmm0
    132f:	f2 0f 58 d1          	addsd  xmm2,xmm1
    1333:	f2 0f 11 54 24 08    	movsd  QWORD PTR [rsp+0x8],xmm2
    1339:	48 8d 3d c4 0c 00 00 	lea    rdi,[rip+0xcc4]        # 2004 <_IO_stdin_used+0x4>
    1340:	e8 3b fd ff ff       	call   1080 <puts@plt>
    1345:	ba 00 e1 f5 05       	mov    edx,0x5f5e100
    134a:	f2 0f 10 04 24       	movsd  xmm0,QWORD PTR [rsp]
    134f:	48 8d 35 d2 0c 00 00 	lea    rsi,[rip+0xcd2]        # 2028 <_IO_stdin_used+0x28>
    1356:	bf 02 00 00 00       	mov    edi,0x2
    135b:	b8 01 00 00 00       	mov    eax,0x1
    1360:	e8 4b fd ff ff       	call   10b0 <__printf_chk@plt>
    1365:	ba 80 96 98 00       	mov    edx,0x989680
    136a:	f2 0f 10 44 24 08    	movsd  xmm0,QWORD PTR [rsp+0x8]
    1370:	48 8d 35 e9 0c 00 00 	lea    rsi,[rip+0xce9]        # 2060 <_IO_stdin_used+0x60>
    1377:	bf 02 00 00 00       	mov    edi,0x2
    137c:	b8 01 00 00 00       	mov    eax,0x1
    1381:	e8 2a fd ff ff       	call   10b0 <__printf_chk@plt>
    1386:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
    138b:	48 8d 35 89 0c 00 00 	lea    rsi,[rip+0xc89]        # 201b <_IO_stdin_used+0x1b>
    1392:	bf 02 00 00 00       	mov    edi,0x2
    1397:	b8 00 00 00 00       	mov    eax,0x0
    139c:	e8 0f fd ff ff       	call   10b0 <__printf_chk@plt>
    13a1:	48 8b 44 24 48       	mov    rax,QWORD PTR [rsp+0x48]
    13a6:	64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
    13ad:	00 00 
    13af:	75 0c                	jne    13bd <main+0x170>
    13b1:	b8 00 00 00 00       	mov    eax,0x0
    13b6:	48 83 c4 58          	add    rsp,0x58
    13ba:	5b                   	pop    rbx
    13bb:	5d                   	pop    rbp
    13bc:	c3                   	ret
    13bd:	e8 de fc ff ff       	call   10a0 <__stack_chk_fail@plt>

Disassembly of section .fini:

00000000000013c4 <_fini>:
    13c4:	f3 0f 1e fa          	endbr64
    13c8:	48 83 ec 08          	sub    rsp,0x8
    13cc:	48 83 c4 08          	add    rsp,0x8
    13d0:	c3                   	ret
