
build/02_loop_unrolling_Os:     file format elf64-x86-64


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
    10d9:	e8 f8 01 00 00       	call   12d6 <benchmark_loop_unrolling>
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
    1129:	f2 0f 5e 05 1f 0f 00 	divsd  xmm0,QWORD PTR [rip+0xf1f]        # 2050 <_IO_stdin_used+0x50>
    1130:	00 
    1131:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    1136:	f2 0f 58 c1          	addsd  xmm0,xmm1
    113a:	f2 0f 11 44 24 08    	movsd  QWORD PTR [rsp+0x8],xmm0
    1140:	e8 3b ff ff ff       	call   1080 <puts@plt>
    1145:	48 8b 54 24 10       	mov    rdx,QWORD PTR [rsp+0x10]
    114a:	48 8d 35 c7 0e 00 00 	lea    rsi,[rip+0xec7]        # 2018 <_IO_stdin_used+0x18>
    1151:	31 c0                	xor    eax,eax
    1153:	bf 02 00 00 00       	mov    edi,0x2
    1158:	e8 53 ff ff ff       	call   10b0 <__printf_chk@plt>
    115d:	f2 0f 10 44 24 08    	movsd  xmm0,QWORD PTR [rsp+0x8]
    1163:	48 8d 35 bb 0e 00 00 	lea    rsi,[rip+0xebb]        # 2025 <_IO_stdin_used+0x25>
    116a:	b0 01                	mov    al,0x1
    116c:	bf 02 00 00 00       	mov    edi,0x2
    1171:	e8 3a ff ff ff       	call   10b0 <__printf_chk@plt>
    1176:	31 c0                	xor    eax,eax
    1178:	ba 80 96 98 00       	mov    edx,0x989680
    117d:	48 8d 35 b5 0e 00 00 	lea    rsi,[rip+0xeb5]        # 2039 <_IO_stdin_used+0x39>
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

0000000000001299 <sum_small_array>:
    1299:	f3 0f 1e fa          	endbr64
    129d:	31 c0                	xor    eax,eax
    129f:	31 d2                	xor    edx,edx
    12a1:	03 14 87             	add    edx,DWORD PTR [rdi+rax*4]
    12a4:	48 ff c0             	inc    rax
    12a7:	48 83 f8 08          	cmp    rax,0x8
    12ab:	75 f4                	jne    12a1 <sum_small_array+0x8>
    12ad:	89 d0                	mov    eax,edx
    12af:	c3                   	ret

00000000000012b0 <process_array>:
    12b0:	f3 0f 1e fa          	endbr64
    12b4:	31 f6                	xor    esi,esi
    12b6:	31 c9                	xor    ecx,ecx
    12b8:	41 b8 02 00 00 00    	mov    r8d,0x2
    12be:	8b 04 b7             	mov    eax,DWORD PTR [rdi+rsi*4]
    12c1:	48 ff c6             	inc    rsi
    12c4:	99                   	cdq
    12c5:	8d 0c 41             	lea    ecx,[rcx+rax*2]
    12c8:	41 f7 f8             	idiv   r8d
    12cb:	29 c1                	sub    ecx,eax
    12cd:	48 83 fe 08          	cmp    rsi,0x8
    12d1:	75 eb                	jne    12be <process_array+0xe>
    12d3:	89 c8                	mov    eax,ecx
    12d5:	c3                   	ret

00000000000012d6 <benchmark_loop_unrolling>:
    12d6:	f3 0f 1e fa          	endbr64
    12da:	48 83 ec 38          	sub    rsp,0x38
    12de:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    12e5:	00 00 
    12e7:	48 89 44 24 28       	mov    QWORD PTR [rsp+0x28],rax
    12ec:	48 b8 01 00 00 00 02 	movabs rax,0x200000001
    12f3:	00 00 00 
    12f6:	48 8d 7c 24 08       	lea    rdi,[rsp+0x8]
    12fb:	48 89 44 24 08       	mov    QWORD PTR [rsp+0x8],rax
    1300:	48 b8 03 00 00 00 04 	movabs rax,0x400000003
    1307:	00 00 00 
    130a:	48 89 44 24 10       	mov    QWORD PTR [rsp+0x10],rax
    130f:	48 b8 05 00 00 00 06 	movabs rax,0x600000005
    1316:	00 00 00 
    1319:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    131e:	48 b8 07 00 00 00 08 	movabs rax,0x800000007
    1325:	00 00 00 
    1328:	48 89 44 24 20       	mov    QWORD PTR [rsp+0x20],rax
    132d:	e8 67 ff ff ff       	call   1299 <sum_small_array>
    1332:	4c 63 c8             	movsxd r9,eax
    1335:	e8 76 ff ff ff       	call   12b0 <process_array>
    133a:	48 98                	cdqe
    133c:	49 01 c1             	add    r9,rax
    133f:	49 69 c1 80 96 98 00 	imul   rax,r9,0x989680
    1346:	48 8b 54 24 28       	mov    rdx,QWORD PTR [rsp+0x28]
    134b:	64 48 2b 14 25 28 00 	sub    rdx,QWORD PTR fs:0x28
    1352:	00 00 
    1354:	74 05                	je     135b <benchmark_loop_unrolling+0x85>
    1356:	e8 45 fd ff ff       	call   10a0 <__stack_chk_fail@plt>
    135b:	48 83 c4 38          	add    rsp,0x38
    135f:	c3                   	ret

Disassembly of section .fini:

0000000000001360 <_fini>:
    1360:	f3 0f 1e fa          	endbr64
    1364:	48 83 ec 08          	sub    rsp,0x8
    1368:	48 83 c4 08          	add    rsp,0x8
    136c:	c3                   	ret
