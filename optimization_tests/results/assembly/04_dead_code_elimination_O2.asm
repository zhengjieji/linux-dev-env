
build/04_dead_code_elimination_O2:     file format elf64-x86-64


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
    10c5:	bf 01 00 00 00       	mov    edi,0x1
    10ca:	48 bb 80 59 80 70 79 	movabs rbx,0x11c37970805980
    10d1:	c3 11 00 
    10d4:	48 83 ec 50          	sub    rsp,0x50
    10d8:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    10df:	00 00 
    10e1:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
    10e6:	31 c0                	xor    eax,eax
    10e8:	48 8d 74 24 20       	lea    rsi,[rsp+0x20]
    10ed:	48 89 5c 24 18       	mov    QWORD PTR [rsp+0x18],rbx
    10f2:	e8 99 ff ff ff       	call   1090 <clock_gettime@plt>
    10f7:	48 8d 74 24 30       	lea    rsi,[rsp+0x30]
    10fc:	bf 01 00 00 00       	mov    edi,0x1
    1101:	48 89 5c 24 18       	mov    QWORD PTR [rsp+0x18],rbx
    1106:	e8 85 ff ff ff       	call   1090 <clock_gettime@plt>
    110b:	48 8b 44 24 38       	mov    rax,QWORD PTR [rsp+0x38]
    1110:	66 0f ef c0          	pxor   xmm0,xmm0
    1114:	48 2b 44 24 28       	sub    rax,QWORD PTR [rsp+0x28]
    1119:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
    111e:	66 0f ef c9          	pxor   xmm1,xmm1
    1122:	48 8b 44 24 30       	mov    rax,QWORD PTR [rsp+0x30]
    1127:	48 2b 44 24 20       	sub    rax,QWORD PTR [rsp+0x20]
    112c:	f2 48 0f 2a c8       	cvtsi2sd xmm1,rax
    1131:	f2 0f 5e 05 17 0f 00 	divsd  xmm0,QWORD PTR [rip+0xf17]        # 2050 <_IO_stdin_used+0x50>
    1138:	00 
    1139:	48 8d 3d c4 0e 00 00 	lea    rdi,[rip+0xec4]        # 2004 <_IO_stdin_used+0x4>
    1140:	f2 0f 58 c1          	addsd  xmm0,xmm1
    1144:	f2 0f 11 44 24 08    	movsd  QWORD PTR [rsp+0x8],xmm0
    114a:	e8 31 ff ff ff       	call   1080 <puts@plt>
    114f:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
    1154:	48 8d 35 c4 0e 00 00 	lea    rsi,[rip+0xec4]        # 201f <_IO_stdin_used+0x1f>
    115b:	31 c0                	xor    eax,eax
    115d:	bf 02 00 00 00       	mov    edi,0x2
    1162:	e8 49 ff ff ff       	call   10b0 <__printf_chk@plt>
    1167:	f2 0f 10 44 24 08    	movsd  xmm0,QWORD PTR [rsp+0x8]
    116d:	bf 02 00 00 00       	mov    edi,0x2
    1172:	48 8d 35 b3 0e 00 00 	lea    rsi,[rip+0xeb3]        # 202c <_IO_stdin_used+0x2c>
    1179:	b8 01 00 00 00       	mov    eax,0x1
    117e:	e8 2d ff ff ff       	call   10b0 <__printf_chk@plt>
    1183:	31 c0                	xor    eax,eax
    1185:	ba 00 e1 f5 05       	mov    edx,0x5f5e100
    118a:	48 8d 35 af 0e 00 00 	lea    rsi,[rip+0xeaf]        # 2040 <_IO_stdin_used+0x40>
    1191:	bf 02 00 00 00       	mov    edi,0x2
    1196:	e8 15 ff ff ff       	call   10b0 <__printf_chk@plt>
    119b:	48 8b 44 24 48       	mov    rax,QWORD PTR [rsp+0x48]
    11a0:	64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
    11a7:	00 00 
    11a9:	75 08                	jne    11b3 <main+0xf3>
    11ab:	48 83 c4 50          	add    rsp,0x50
    11af:	31 c0                	xor    eax,eax
    11b1:	5b                   	pop    rbx
    11b2:	c3                   	ret
    11b3:	e8 e8 fe ff ff       	call   10a0 <__stack_chk_fail@plt>
    11b8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    11bf:	00 

00000000000011c0 <_start>:
    11c0:	f3 0f 1e fa          	endbr64
    11c4:	31 ed                	xor    ebp,ebp
    11c6:	49 89 d1             	mov    r9,rdx
    11c9:	5e                   	pop    rsi
    11ca:	48 89 e2             	mov    rdx,rsp
    11cd:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
    11d1:	50                   	push   rax
    11d2:	54                   	push   rsp
    11d3:	45 31 c0             	xor    r8d,r8d
    11d6:	31 c9                	xor    ecx,ecx
    11d8:	48 8d 3d e1 fe ff ff 	lea    rdi,[rip+0xfffffffffffffee1]        # 10c0 <main>
    11df:	ff 15 f3 2d 00 00    	call   QWORD PTR [rip+0x2df3]        # 3fd8 <__libc_start_main@GLIBC_2.34>
    11e5:	f4                   	hlt
    11e6:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    11ed:	00 00 00 

00000000000011f0 <deregister_tm_clones>:
    11f0:	48 8d 3d 19 2e 00 00 	lea    rdi,[rip+0x2e19]        # 4010 <__TMC_END__>
    11f7:	48 8d 05 12 2e 00 00 	lea    rax,[rip+0x2e12]        # 4010 <__TMC_END__>
    11fe:	48 39 f8             	cmp    rax,rdi
    1201:	74 15                	je     1218 <deregister_tm_clones+0x28>
    1203:	48 8b 05 d6 2d 00 00 	mov    rax,QWORD PTR [rip+0x2dd6]        # 3fe0 <_ITM_deregisterTMCloneTable@Base>
    120a:	48 85 c0             	test   rax,rax
    120d:	74 09                	je     1218 <deregister_tm_clones+0x28>
    120f:	ff e0                	jmp    rax
    1211:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    1218:	c3                   	ret
    1219:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001220 <register_tm_clones>:
    1220:	48 8d 3d e9 2d 00 00 	lea    rdi,[rip+0x2de9]        # 4010 <__TMC_END__>
    1227:	48 8d 35 e2 2d 00 00 	lea    rsi,[rip+0x2de2]        # 4010 <__TMC_END__>
    122e:	48 29 fe             	sub    rsi,rdi
    1231:	48 89 f0             	mov    rax,rsi
    1234:	48 c1 ee 3f          	shr    rsi,0x3f
    1238:	48 c1 f8 03          	sar    rax,0x3
    123c:	48 01 c6             	add    rsi,rax
    123f:	48 d1 fe             	sar    rsi,1
    1242:	74 14                	je     1258 <register_tm_clones+0x38>
    1244:	48 8b 05 a5 2d 00 00 	mov    rax,QWORD PTR [rip+0x2da5]        # 3ff0 <_ITM_registerTMCloneTable@Base>
    124b:	48 85 c0             	test   rax,rax
    124e:	74 08                	je     1258 <register_tm_clones+0x38>
    1250:	ff e0                	jmp    rax
    1252:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    1258:	c3                   	ret
    1259:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000001260 <__do_global_dtors_aux>:
    1260:	f3 0f 1e fa          	endbr64
    1264:	80 3d a5 2d 00 00 00 	cmp    BYTE PTR [rip+0x2da5],0x0        # 4010 <__TMC_END__>
    126b:	75 2b                	jne    1298 <__do_global_dtors_aux+0x38>
    126d:	55                   	push   rbp
    126e:	48 83 3d 82 2d 00 00 	cmp    QWORD PTR [rip+0x2d82],0x0        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    1275:	00 
    1276:	48 89 e5             	mov    rbp,rsp
    1279:	74 0c                	je     1287 <__do_global_dtors_aux+0x27>
    127b:	48 8b 3d 86 2d 00 00 	mov    rdi,QWORD PTR [rip+0x2d86]        # 4008 <__dso_handle>
    1282:	e8 e9 fd ff ff       	call   1070 <__cxa_finalize@plt>
    1287:	e8 64 ff ff ff       	call   11f0 <deregister_tm_clones>
    128c:	c6 05 7d 2d 00 00 01 	mov    BYTE PTR [rip+0x2d7d],0x1        # 4010 <__TMC_END__>
    1293:	5d                   	pop    rbp
    1294:	c3                   	ret
    1295:	0f 1f 00             	nop    DWORD PTR [rax]
    1298:	c3                   	ret
    1299:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000012a0 <frame_dummy>:
    12a0:	f3 0f 1e fa          	endbr64
    12a4:	e9 77 ff ff ff       	jmp    1220 <register_tm_clones>
    12a9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000012b0 <compute_with_dead_code>:
    12b0:	f3 0f 1e fa          	endbr64
    12b4:	8d 47 0a             	lea    eax,[rdi+0xa]
    12b7:	c3                   	ret
    12b8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    12bf:	00 

00000000000012c0 <compute_optimized>:
    12c0:	f3 0f 1e fa          	endbr64
    12c4:	8d 47 0a             	lea    eax,[rdi+0xa]
    12c7:	c3                   	ret
    12c8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    12cf:	00 

00000000000012d0 <benchmark_dead_code_elimination>:
    12d0:	f3 0f 1e fa          	endbr64
    12d4:	48 b8 80 59 80 70 79 	movabs rax,0x11c37970805980
    12db:	c3 11 00 
    12de:	c3                   	ret

Disassembly of section .fini:

00000000000012e0 <_fini>:
    12e0:	f3 0f 1e fa          	endbr64
    12e4:	48 83 ec 08          	sub    rsp,0x8
    12e8:	48 83 c4 08          	add    rsp,0x8
    12ec:	c3                   	ret
