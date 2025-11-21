
build/06_cse_O0:     file format elf64-x86-64


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
    10d8:	48 8d 3d 21 03 00 00 	lea    rdi,[rip+0x321]        # 1400 <main>
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
    11ad:	55                   	push   rbp
    11ae:	48 89 e5             	mov    rbp,rsp
    11b1:	89 7d ec             	mov    DWORD PTR [rbp-0x14],edi
    11b4:	89 75 e8             	mov    DWORD PTR [rbp-0x18],esi
    11b7:	8b 55 ec             	mov    edx,DWORD PTR [rbp-0x14]
    11ba:	8b 45 e8             	mov    eax,DWORD PTR [rbp-0x18]
    11bd:	01 d0                	add    eax,edx
    11bf:	01 c0                	add    eax,eax
    11c1:	89 45 f0             	mov    DWORD PTR [rbp-0x10],eax
    11c4:	8b 55 ec             	mov    edx,DWORD PTR [rbp-0x14]
    11c7:	8b 45 e8             	mov    eax,DWORD PTR [rbp-0x18]
    11ca:	01 c2                	add    edx,eax
    11cc:	89 d0                	mov    eax,edx
    11ce:	01 c0                	add    eax,eax
    11d0:	01 d0                	add    eax,edx
    11d2:	89 45 f4             	mov    DWORD PTR [rbp-0xc],eax
    11d5:	8b 55 ec             	mov    edx,DWORD PTR [rbp-0x14]
    11d8:	8b 45 e8             	mov    eax,DWORD PTR [rbp-0x18]
    11db:	01 d0                	add    eax,edx
    11dd:	83 c0 0a             	add    eax,0xa
    11e0:	89 45 f8             	mov    DWORD PTR [rbp-0x8],eax
    11e3:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    11e6:	8d 0c 00             	lea    ecx,[rax+rax*1]
    11e9:	8b 55 e8             	mov    edx,DWORD PTR [rbp-0x18]
    11ec:	89 d0                	mov    eax,edx
    11ee:	01 c0                	add    eax,eax
    11f0:	01 d0                	add    eax,edx
    11f2:	01 c8                	add    eax,ecx
    11f4:	c1 e0 02             	shl    eax,0x2
    11f7:	01 45 f0             	add    DWORD PTR [rbp-0x10],eax
    11fa:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    11fd:	8d 0c 00             	lea    ecx,[rax+rax*1]
    1200:	8b 55 e8             	mov    edx,DWORD PTR [rbp-0x18]
    1203:	89 d0                	mov    eax,edx
    1205:	01 c0                	add    eax,eax
    1207:	01 d0                	add    eax,edx
    1209:	8d 14 01             	lea    edx,[rcx+rax*1]
    120c:	89 d0                	mov    eax,edx
    120e:	c1 e0 02             	shl    eax,0x2
    1211:	01 d0                	add    eax,edx
    1213:	01 45 f4             	add    DWORD PTR [rbp-0xc],eax
    1216:	8b 55 f0             	mov    edx,DWORD PTR [rbp-0x10]
    1219:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    121c:	01 d0                	add    eax,edx
    121e:	89 c2                	mov    edx,eax
    1220:	c1 ea 1f             	shr    edx,0x1f
    1223:	01 d0                	add    eax,edx
    1225:	d1 f8                	sar    eax,1
    1227:	89 45 f8             	mov    DWORD PTR [rbp-0x8],eax
    122a:	8b 55 f0             	mov    edx,DWORD PTR [rbp-0x10]
    122d:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    1230:	01 d0                	add    eax,edx
    1232:	48 63 d0             	movsxd rdx,eax
    1235:	48 69 d2 56 55 55 55 	imul   rdx,rdx,0x55555556
    123c:	48 89 d1             	mov    rcx,rdx
    123f:	48 c1 e9 20          	shr    rcx,0x20
    1243:	99                   	cdq
    1244:	89 c8                	mov    eax,ecx
    1246:	29 d0                	sub    eax,edx
    1248:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    124b:	8b 55 f0             	mov    edx,DWORD PTR [rbp-0x10]
    124e:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    1251:	01 c2                	add    edx,eax
    1253:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]
    1256:	01 c2                	add    edx,eax
    1258:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    125b:	01 d0                	add    eax,edx
    125d:	5d                   	pop    rbp
    125e:	c3                   	ret

000000000000125f <compute_optimized>:
    125f:	f3 0f 1e fa          	endbr64
    1263:	55                   	push   rbp
    1264:	48 89 e5             	mov    rbp,rsp
    1267:	89 7d dc             	mov    DWORD PTR [rbp-0x24],edi
    126a:	89 75 d8             	mov    DWORD PTR [rbp-0x28],esi
    126d:	8b 55 dc             	mov    edx,DWORD PTR [rbp-0x24]
    1270:	8b 45 d8             	mov    eax,DWORD PTR [rbp-0x28]
    1273:	01 d0                	add    eax,edx
    1275:	89 45 e4             	mov    DWORD PTR [rbp-0x1c],eax
    1278:	8b 45 dc             	mov    eax,DWORD PTR [rbp-0x24]
    127b:	8d 0c 00             	lea    ecx,[rax+rax*1]
    127e:	8b 55 d8             	mov    edx,DWORD PTR [rbp-0x28]
    1281:	89 d0                	mov    eax,edx
    1283:	01 c0                	add    eax,eax
    1285:	01 d0                	add    eax,edx
    1287:	01 c8                	add    eax,ecx
    1289:	89 45 e8             	mov    DWORD PTR [rbp-0x18],eax
    128c:	8b 45 e4             	mov    eax,DWORD PTR [rbp-0x1c]
    128f:	01 c0                	add    eax,eax
    1291:	89 45 ec             	mov    DWORD PTR [rbp-0x14],eax
    1294:	8b 55 e4             	mov    edx,DWORD PTR [rbp-0x1c]
    1297:	89 d0                	mov    eax,edx
    1299:	01 c0                	add    eax,eax
    129b:	01 d0                	add    eax,edx
    129d:	89 45 f0             	mov    DWORD PTR [rbp-0x10],eax
    12a0:	8b 45 e4             	mov    eax,DWORD PTR [rbp-0x1c]
    12a3:	83 c0 0a             	add    eax,0xa
    12a6:	89 45 f4             	mov    DWORD PTR [rbp-0xc],eax
    12a9:	8b 45 e8             	mov    eax,DWORD PTR [rbp-0x18]
    12ac:	c1 e0 02             	shl    eax,0x2
    12af:	01 45 ec             	add    DWORD PTR [rbp-0x14],eax
    12b2:	8b 55 e8             	mov    edx,DWORD PTR [rbp-0x18]
    12b5:	89 d0                	mov    eax,edx
    12b7:	c1 e0 02             	shl    eax,0x2
    12ba:	01 d0                	add    eax,edx
    12bc:	01 45 f0             	add    DWORD PTR [rbp-0x10],eax
    12bf:	8b 55 ec             	mov    edx,DWORD PTR [rbp-0x14]
    12c2:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
    12c5:	01 d0                	add    eax,edx
    12c7:	89 45 f8             	mov    DWORD PTR [rbp-0x8],eax
    12ca:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]
    12cd:	89 c2                	mov    edx,eax
    12cf:	c1 ea 1f             	shr    edx,0x1f
    12d2:	01 d0                	add    eax,edx
    12d4:	d1 f8                	sar    eax,1
    12d6:	89 45 f4             	mov    DWORD PTR [rbp-0xc],eax
    12d9:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]
    12dc:	48 63 d0             	movsxd rdx,eax
    12df:	48 69 d2 56 55 55 55 	imul   rdx,rdx,0x55555556
    12e6:	48 89 d1             	mov    rcx,rdx
    12e9:	48 c1 e9 20          	shr    rcx,0x20
    12ed:	99                   	cdq
    12ee:	89 c8                	mov    eax,ecx
    12f0:	29 d0                	sub    eax,edx
    12f2:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
    12f5:	8b 55 ec             	mov    edx,DWORD PTR [rbp-0x14]
    12f8:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
    12fb:	01 c2                	add    edx,eax
    12fd:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    1300:	01 c2                	add    edx,eax
    1302:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    1305:	01 d0                	add    eax,edx
    1307:	5d                   	pop    rbp
    1308:	c3                   	ret

0000000000001309 <complex_computation>:
    1309:	f3 0f 1e fa          	endbr64
    130d:	55                   	push   rbp
    130e:	48 89 e5             	mov    rbp,rsp
    1311:	89 7d ec             	mov    DWORD PTR [rbp-0x14],edi
    1314:	89 75 e8             	mov    DWORD PTR [rbp-0x18],esi
    1317:	89 55 e4             	mov    DWORD PTR [rbp-0x1c],edx
    131a:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
    1321:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    1324:	0f af c0             	imul   eax,eax
    1327:	89 c2                	mov    edx,eax
    1329:	8b 45 e8             	mov    eax,DWORD PTR [rbp-0x18]
    132c:	0f af c0             	imul   eax,eax
    132f:	01 d0                	add    eax,edx
    1331:	01 c0                	add    eax,eax
    1333:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    1336:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    1339:	0f af c0             	imul   eax,eax
    133c:	89 c2                	mov    edx,eax
    133e:	8b 45 e8             	mov    eax,DWORD PTR [rbp-0x18]
    1341:	0f af c0             	imul   eax,eax
    1344:	01 d0                	add    eax,edx
    1346:	48 63 d0             	movsxd rdx,eax
    1349:	48 69 d2 56 55 55 55 	imul   rdx,rdx,0x55555556
    1350:	48 89 d1             	mov    rcx,rdx
    1353:	48 c1 e9 20          	shr    rcx,0x20
    1357:	99                   	cdq
    1358:	89 c8                	mov    eax,ecx
    135a:	29 d0                	sub    eax,edx
    135c:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    135f:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]
    1362:	0f af c0             	imul   eax,eax
    1365:	89 c2                	mov    edx,eax
    1367:	8b 45 e8             	mov    eax,DWORD PTR [rbp-0x18]
    136a:	0f af c0             	imul   eax,eax
    136d:	01 d0                	add    eax,edx
    136f:	2b 45 e4             	sub    eax,DWORD PTR [rbp-0x1c]
    1372:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    1375:	8b 55 ec             	mov    edx,DWORD PTR [rbp-0x14]
    1378:	8b 45 e8             	mov    eax,DWORD PTR [rbp-0x18]
    137b:	01 c2                	add    edx,eax
    137d:	8b 45 e4             	mov    eax,DWORD PTR [rbp-0x1c]
    1380:	01 c2                	add    edx,eax
    1382:	8b 4d ec             	mov    ecx,DWORD PTR [rbp-0x14]
    1385:	8b 45 e8             	mov    eax,DWORD PTR [rbp-0x18]
    1388:	01 c1                	add    ecx,eax
    138a:	8b 45 e4             	mov    eax,DWORD PTR [rbp-0x1c]
    138d:	01 c8                	add    eax,ecx
    138f:	0f af c2             	imul   eax,edx
    1392:	01 45 fc             	add    DWORD PTR [rbp-0x4],eax
    1395:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    1398:	5d                   	pop    rbp
    1399:	c3                   	ret

000000000000139a <benchmark_cse>:
    139a:	f3 0f 1e fa          	endbr64
    139e:	55                   	push   rbp
    139f:	48 89 e5             	mov    rbp,rsp
    13a2:	48 83 ec 10          	sub    rsp,0x10
    13a6:	48 c7 45 f8 00 00 00 	mov    QWORD PTR [rbp-0x8],0x0
    13ad:	00 
    13ae:	c7 45 f4 00 00 00 00 	mov    DWORD PTR [rbp-0xc],0x0
    13b5:	eb 3a                	jmp    13f1 <benchmark_cse+0x57>
    13b7:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    13ba:	8d 50 01             	lea    edx,[rax+0x1]
    13bd:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    13c0:	89 d6                	mov    esi,edx
    13c2:	89 c7                	mov    edi,eax
    13c4:	e8 e0 fd ff ff       	call   11a9 <compute_with_redundancy>
    13c9:	48 98                	cdqe
    13cb:	48 01 45 f8          	add    QWORD PTR [rbp-0x8],rax
    13cf:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    13d2:	8d 50 02             	lea    edx,[rax+0x2]
    13d5:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    13d8:	8d 48 01             	lea    ecx,[rax+0x1]
    13db:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    13de:	89 ce                	mov    esi,ecx
    13e0:	89 c7                	mov    edi,eax
    13e2:	e8 22 ff ff ff       	call   1309 <complex_computation>
    13e7:	48 98                	cdqe
    13e9:	48 01 45 f8          	add    QWORD PTR [rbp-0x8],rax
    13ed:	83 45 f4 01          	add    DWORD PTR [rbp-0xc],0x1
    13f1:	81 7d f4 7f f0 fa 02 	cmp    DWORD PTR [rbp-0xc],0x2faf07f
    13f8:	7e bd                	jle    13b7 <benchmark_cse+0x1d>
    13fa:	48 8b 45 f8          	mov    rax,QWORD PTR [rbp-0x8]
    13fe:	c9                   	leave
    13ff:	c3                   	ret

0000000000001400 <main>:
    1400:	f3 0f 1e fa          	endbr64
    1404:	55                   	push   rbp
    1405:	48 89 e5             	mov    rbp,rsp
    1408:	48 83 ec 40          	sub    rsp,0x40
    140c:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    1413:	00 00 
    1415:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax
    1419:	31 c0                	xor    eax,eax
    141b:	b8 00 00 00 00       	mov    eax,0x0
    1420:	e8 75 ff ff ff       	call   139a <benchmark_cse>
    1425:	48 89 45 c0          	mov    QWORD PTR [rbp-0x40],rax
    1429:	48 8d 45 d0          	lea    rax,[rbp-0x30]
    142d:	48 89 c6             	mov    rsi,rax
    1430:	bf 01 00 00 00       	mov    edi,0x1
    1435:	e8 56 fc ff ff       	call   1090 <clock_gettime@plt>
    143a:	b8 00 00 00 00       	mov    eax,0x0
    143f:	e8 56 ff ff ff       	call   139a <benchmark_cse>
    1444:	48 89 45 c0          	mov    QWORD PTR [rbp-0x40],rax
    1448:	48 8d 45 e0          	lea    rax,[rbp-0x20]
    144c:	48 89 c6             	mov    rsi,rax
    144f:	bf 01 00 00 00       	mov    edi,0x1
    1454:	e8 37 fc ff ff       	call   1090 <clock_gettime@plt>
    1459:	48 8b 55 e0          	mov    rdx,QWORD PTR [rbp-0x20]
    145d:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    1461:	48 29 c2             	sub    rdx,rax
    1464:	66 0f ef c9          	pxor   xmm1,xmm1
    1468:	f2 48 0f 2a ca       	cvtsi2sd xmm1,rdx
    146d:	48 8b 55 e8          	mov    rdx,QWORD PTR [rbp-0x18]
    1471:	48 8b 45 d8          	mov    rax,QWORD PTR [rbp-0x28]
    1475:	48 29 c2             	sub    rdx,rax
    1478:	66 0f ef c0          	pxor   xmm0,xmm0
    147c:	f2 48 0f 2a c2       	cvtsi2sd xmm0,rdx
    1481:	f2 0f 10 15 d7 0b 00 	movsd  xmm2,QWORD PTR [rip+0xbd7]        # 2060 <_IO_stdin_used+0x60>
    1488:	00 
    1489:	f2 0f 5e c2          	divsd  xmm0,xmm2
    148d:	f2 0f 58 c1          	addsd  xmm0,xmm1
    1491:	f2 0f 11 45 c8       	movsd  QWORD PTR [rbp-0x38],xmm0
    1496:	48 8d 05 6b 0b 00 00 	lea    rax,[rip+0xb6b]        # 2008 <_IO_stdin_used+0x8>
    149d:	48 89 c7             	mov    rdi,rax
    14a0:	e8 db fb ff ff       	call   1080 <puts@plt>
    14a5:	48 8b 45 c0          	mov    rax,QWORD PTR [rbp-0x40]
    14a9:	48 89 c6             	mov    rsi,rax
    14ac:	48 8d 05 7b 0b 00 00 	lea    rax,[rip+0xb7b]        # 202e <_IO_stdin_used+0x2e>
    14b3:	48 89 c7             	mov    rdi,rax
    14b6:	b8 00 00 00 00       	mov    eax,0x0
    14bb:	e8 f0 fb ff ff       	call   10b0 <printf@plt>
    14c0:	48 8b 45 c8          	mov    rax,QWORD PTR [rbp-0x38]
    14c4:	66 48 0f 6e c0       	movq   xmm0,rax
    14c9:	48 8d 05 6b 0b 00 00 	lea    rax,[rip+0xb6b]        # 203b <_IO_stdin_used+0x3b>
    14d0:	48 89 c7             	mov    rdi,rax
    14d3:	b8 01 00 00 00       	mov    eax,0x1
    14d8:	e8 d3 fb ff ff       	call   10b0 <printf@plt>
    14dd:	be 80 f0 fa 02       	mov    esi,0x2faf080
    14e2:	48 8d 05 66 0b 00 00 	lea    rax,[rip+0xb66]        # 204f <_IO_stdin_used+0x4f>
    14e9:	48 89 c7             	mov    rdi,rax
    14ec:	b8 00 00 00 00       	mov    eax,0x0
    14f1:	e8 ba fb ff ff       	call   10b0 <printf@plt>
    14f6:	b8 00 00 00 00       	mov    eax,0x0
    14fb:	48 8b 55 f8          	mov    rdx,QWORD PTR [rbp-0x8]
    14ff:	64 48 2b 14 25 28 00 	sub    rdx,QWORD PTR fs:0x28
    1506:	00 00 
    1508:	74 05                	je     150f <main+0x10f>
    150a:	e8 91 fb ff ff       	call   10a0 <__stack_chk_fail@plt>
    150f:	c9                   	leave
    1510:	c3                   	ret

Disassembly of section .fini:

0000000000001514 <_fini>:
    1514:	f3 0f 1e fa          	endbr64
    1518:	48 83 ec 08          	sub    rsp,0x8
    151c:	48 83 c4 08          	add    rsp,0x8
    1520:	c3                   	ret
