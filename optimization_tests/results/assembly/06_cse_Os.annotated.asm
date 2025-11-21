
build/06_cse_Os:     file format elf64-x86-64


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
    10c5:	48 83 ec 40          	sub    rsp,0x40
    10c9:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    10d0:	00 00 
    10d2:	48 89 44 24 38       	mov    QWORD PTR [rsp+0x38],rax
    10d7:	31 c0                	xor    eax,eax
    10d9:	e8 66 02 00 00       	call   1344 <benchmark_cse>
    10de:	48 8d 74 24 18       	lea    rsi,[rsp+0x18]
    10e3:	bf 01 00 00 00       	mov    edi,0x1
    10e8:	48 89 c3             	mov    rbx,rax
    10eb:	48 89 44 24 10       	mov    QWORD PTR [rsp+0x10],rax
    10f0:	e8 9b ff ff ff       	call   1090 <clock_gettime@plt>
    10f5:	48 8d 74 24 28       	lea    rsi,[rsp+0x28]
    10fa:	bf 01 00 00 00       	mov    edi,0x1
    10ff:	48 89 5c 24 10       	mov    QWORD PTR [rsp+0x10],rbx
    1104:	e8 87 ff ff ff       	call   1090 <clock_gettime@plt>
    1109:	48 8b 44 24 30       	mov    rax,QWORD PTR [rsp+0x30]
    110e:	48 2b 44 24 20       	sub    rax,QWORD PTR [rsp+0x20]
    1113:	48 8d 3d ea 0e 00 00 	lea    rdi,[rip+0xeea]        # 2004 <_IO_stdin_used+0x4>
    111a:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    111f:	48 8b 44 24 28       	mov    rax,QWORD PTR [rsp+0x28]
    1124:	48 2b 44 24 18       	sub    rax,QWORD PTR [rsp+0x18]
    1129:	f2 0f 5e 05 2f 0f 00 	divsd  xmm0,QWORD PTR [rip+0xf2f]        # 2060 <_IO_stdin_used+0x60>
    1130:	00 
    1131:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    1136:	f2 0f 58 c1          	addsd  xmm0,xmm1
    113a:	f2 0f 11 44 24 08    	movsd  QWORD PTR [rsp+0x8],xmm0
    1140:	e8 3b ff ff ff       	call   1080 <puts@plt>
    1145:	48 8b 54 24 10       	mov    rdx,QWORD PTR [rsp+0x10]
    114a:	48 8d 35 d9 0e 00 00 	lea    rsi,[rip+0xed9]        # 202a <_IO_stdin_used+0x2a>
    1151:	31 c0                	xor    eax,eax
    1153:	bf 02 00 00 00       	mov    edi,0x2
    1158:	e8 53 ff ff ff       	call   10b0 <__printf_chk@plt>
    115d:	f2 0f 10 44 24 08    	movsd  xmm0,QWORD PTR [rsp+0x8]
    1163:	48 8d 35 cd 0e 00 00 	lea    rsi,[rip+0xecd]        # 2037 <_IO_stdin_used+0x37>
    116a:	b0 01                	mov    al,0x1
    116c:	bf 02 00 00 00       	mov    edi,0x2
    1171:	e8 3a ff ff ff       	call   10b0 <__printf_chk@plt>
    1176:	31 c0                	xor    eax,eax
    1178:	ba 80 f0 fa 02       	mov    edx,0x2faf080
    117d:	48 8d 35 c7 0e 00 00 	lea    rsi,[rip+0xec7]        # 204b <_IO_stdin_used+0x4b>
    1184:	bf 02 00 00 00       	mov    edi,0x2
    1189:	e8 22 ff ff ff       	call   10b0 <__printf_chk@plt>
    118e:	48 8b 44 24 38       	mov    rax,QWORD PTR [rsp+0x38]
    1193:	64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
    119a:	00 00 
    119c:	74 05                	je     11a3 <main+0xe3>
    119e:	e8 fd fe ff ff       	call   10a0 <__stack_chk_fail@plt>
    11a3:	48 83 c4 40          	add    rsp,0x40
    11a7:	31 c0                	xor    eax,eax
    11a9:	5b                   	pop    rbx
    11aa:	c3                   	ret
    11ab:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

00000000000011b0 <_start>:
    11b0:	f3 0f 1e fa          	endbr64
    11b4:	31 ed                	xor    ebp,ebp
    11b6:	49 89 d1             	mov    r9,rdx
    11b9:	5e                   	pop    rsi
    11ba:	48 89 e2             	mov    rdx,rsp
    11bd:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
    11c1:	50                   	push   rax
    11c2:	54                   	push   rsp
    11c3:	45 31 c0             	xor    r8d,r8d
    11c6:	31 c9                	xor    ecx,ecx
    11c8:	48 8d 3d f1 fe ff ff 	lea    rdi,[rip+0xfffffffffffffef1]        # 10c0 <main>
    11cf:	ff 15 03 2e 00 00    	call   QWORD PTR [rip+0x2e03]        # 3fd8 <__libc_start_main@GLIBC_2.34>
    11d5:	f4                   	hlt
    11d6:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    11dd:	00 00 00 

00000000000011e0 <deregister_tm_clones>:
    11e0:	48 8d 3d 29 2e 00 00 	lea    rdi,[rip+0x2e29]        # 4010 <__TMC_END__>
    11e7:	48 8d 05 22 2e 00 00 	lea    rax,[rip+0x2e22]        # 4010 <__TMC_END__>
    11ee:	48 39 f8             	cmp    rax,rdi
    11f1:	74 15                	je     1208 <deregister_tm_clones+0x28>
    11f3:	48 8b 05 e6 2d 00 00 	mov    rax,QWORD PTR [rip+0x2de6]        # 3fe0 <_ITM_deregisterTMCloneTable@Base>
    11fa:	48 85 c0             	test   rax,rax
    11fd:	74 09                	je     1208 <deregister_tm_clones+0x28>
    11ff:	ff e0                	jmp    rax
    1201:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    1208:	c3                   	ret
    1209:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001210 <register_tm_clones>:
    1210:	48 8d 3d f9 2d 00 00 	lea    rdi,[rip+0x2df9]        # 4010 <__TMC_END__>
    1217:	48 8d 35 f2 2d 00 00 	lea    rsi,[rip+0x2df2]        # 4010 <__TMC_END__>
    121e:	48 29 fe             	sub    rsi,rdi
    1221:	48 89 f0             	mov    rax,rsi
    1224:	48 c1 ee 3f          	shr    rsi,0x3f
    1228:	48 c1 f8 03          	sar    rax,0x3
    122c:	48 01 c6             	add    rsi,rax
    122f:	48 d1 fe             	sar    rsi,1
    1232:	74 14                	je     1248 <register_tm_clones+0x38>
    1234:	48 8b 05 b5 2d 00 00 	mov    rax,QWORD PTR [rip+0x2db5]        # 3ff0 <_ITM_registerTMCloneTable@Base>
    123b:	48 85 c0             	test   rax,rax
    123e:	74 08                	je     1248 <register_tm_clones+0x38>
    1240:	ff e0                	jmp    rax
    1242:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    1248:	c3                   	ret
    1249:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001250 <__do_global_dtors_aux>:
    1250:	f3 0f 1e fa          	endbr64
    1254:	80 3d b5 2d 00 00 00 	cmp    BYTE PTR [rip+0x2db5],0x0        # 4010 <__TMC_END__>
    125b:	75 2b                	jne    1288 <__do_global_dtors_aux+0x38>
    125d:	55                   	push   rbp
    125e:	48 83 3d 92 2d 00 00 	cmp    QWORD PTR [rip+0x2d92],0x0        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    1265:	00 
    1266:	48 89 e5             	mov    rbp,rsp
    1269:	74 0c                	je     1277 <__do_global_dtors_aux+0x27>
    126b:	48 8b 3d 96 2d 00 00 	mov    rdi,QWORD PTR [rip+0x2d96]        # 4008 <__dso_handle>
    1272:	e8 f9 fd ff ff       	call   1070 <__cxa_finalize@plt>
    1277:	e8 64 ff ff ff       	call   11e0 <deregister_tm_clones>
    127c:	c6 05 8d 2d 00 00 01 	mov    BYTE PTR [rip+0x2d8d],0x1        # 4010 <__TMC_END__>
    1283:	5d                   	pop    rbp
    1284:	c3                   	ret
    1285:	0f 1f 00             	nop    DWORD PTR [rax]
    1288:	c3                   	ret
    1289:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001290 <frame_dummy>:
    1290:	f3 0f 1e fa          	endbr64
    1294:	e9 77 ff ff ff       	jmp    1210 <register_tm_clones>

0000000000001299 <compute_with_redundancy>:
    1299:	f3 0f 1e fa          	endbr64
    129d:	8d 14 37             	lea    edx,[rdi+rsi*1]
    12a0:	8d 34 76             	lea    esi,[rsi+rsi*2]
    12a3:	8d 04 7e             	lea    eax,[rsi+rdi*2]
    12a6:	44 8d 04 52          	lea    r8d,[rdx+rdx*2]
    12aa:	be 02 00 00 00       	mov    esi,0x2
    12af:	bf 03 00 00 00       	mov    edi,0x3
    12b4:	8d 0c 85 00 00 00 00 	lea    ecx,[rax*4+0x0]
    12bb:	8d 04 80             	lea    eax,[rax+rax*4]
    12be:	44 01 c0             	add    eax,r8d
    12c1:	8d 0c 51             	lea    ecx,[rcx+rdx*2]
    12c4:	01 c1                	add    ecx,eax
    12c6:	89 c8                	mov    eax,ecx
    12c8:	99                   	cdq
    12c9:	f7 fe                	idiv   esi
    12cb:	8d 34 08             	lea    esi,[rax+rcx*1]
    12ce:	89 c8                	mov    eax,ecx
    12d0:	99                   	cdq
    12d1:	f7 ff                	idiv   edi
    12d3:	01 f0                	add    eax,esi
    12d5:	c3                   	ret

00000000000012d6 <compute_optimized>:
    12d6:	f3 0f 1e fa          	endbr64
    12da:	8d 14 37             	lea    edx,[rdi+rsi*1]
    12dd:	8d 34 76             	lea    esi,[rsi+rsi*2]
    12e0:	8d 04 7e             	lea    eax,[rsi+rdi*2]
    12e3:	8d 34 52             	lea    esi,[rdx+rdx*2]
    12e6:	bf 03 00 00 00       	mov    edi,0x3
    12eb:	8d 0c 85 00 00 00 00 	lea    ecx,[rax*4+0x0]
    12f2:	8d 04 80             	lea    eax,[rax+rax*4]
    12f5:	01 f0                	add    eax,esi
    12f7:	8d 0c 51             	lea    ecx,[rcx+rdx*2]
    12fa:	be 02 00 00 00       	mov    esi,0x2
    12ff:	01 c1                	add    ecx,eax
    1301:	89 c8                	mov    eax,ecx
    1303:	99                   	cdq
    1304:	f7 fe                	idiv   esi
    1306:	8d 34 08             	lea    esi,[rax+rcx*1]
    1309:	89 c8                	mov    eax,ecx
    130b:	99                   	cdq
    130c:	f7 ff                	idiv   edi
    130e:	01 f0                	add    eax,esi
    1310:	c3                   	ret

0000000000001311 <complex_computation>:
    1311:	f3 0f 1e fa          	endbr64
    1315:	89 f0                	mov    eax,esi
    1317:	89 f9                	mov    ecx,edi
    1319:	41 89 d0             	mov    r8d,edx
    131c:	41 b9 03 00 00 00    	mov    r9d,0x3
    1322:	0f af c6             	imul   eax,esi
    1325:	01 f1                	add    ecx,esi
    1327:	0f af ff             	imul   edi,edi
    132a:	01 c7                	add    edi,eax
    132c:	89 f8                	mov    eax,edi
    132e:	99                   	cdq
    132f:	41 f7 f9             	idiv   r9d
    1332:	8d 04 78             	lea    eax,[rax+rdi*2]
    1335:	44 29 c7             	sub    edi,r8d
    1338:	01 c7                	add    edi,eax
    133a:	42 8d 04 01          	lea    eax,[rcx+r8*1]
    133e:	0f af c0             	imul   eax,eax
    1341:	01 f8                	add    eax,edi
    1343:	c3                   	ret

0000000000001344 <benchmark_cse>:
    1344:	f3 0f 1e fa          	endbr64
    1348:	53                   	push   rbx
    1349:	45 31 d2             	xor    r10d,r10d
    134c:	45 31 db             	xor    r11d,r11d
    134f:	44 89 d3             	mov    ebx,r10d
    1352:	41 ff c2             	inc    r10d
    1355:	44 89 d6             	mov    esi,r10d
    1358:	89 df                	mov    edi,ebx
    135a:	e8 3a ff ff ff       	call   1299 <compute_with_redundancy>
    135f:	8d 53 02             	lea    edx,[rbx+0x2]
    1362:	44 89 d6             	mov    esi,r10d
    1365:	89 df                	mov    edi,ebx
    1367:	48 98                	cdqe
    1369:	49 01 c3             	add    r11,rax
    136c:	e8 a0 ff ff ff       	call   1311 <complex_computation>
    1371:	48 98                	cdqe
    1373:	49 01 c3             	add    r11,rax
    1376:	41 81 fa 80 f0 fa 02 	cmp    r10d,0x2faf080
    137d:	75 d0                	jne    134f <benchmark_cse+0xb>
    137f:	4c 89 d8             	mov    rax,r11
    1382:	5b                   	pop    rbx
    1383:	c3                   	ret

Disassembly of section .fini:

0000000000001384 <_fini>:
    1384:	f3 0f 1e fa          	endbr64
    1388:	48 83 ec 08          	sub    rsp,0x8
    138c:	48 83 c4 08          	add    rsp,0x8
    1390:	c3                   	ret
