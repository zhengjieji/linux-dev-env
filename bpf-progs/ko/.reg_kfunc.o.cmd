savedcmd_reg_kfunc.o := gcc -Wp,-MMD,./.reg_kfunc.o.d -nostdinc -I/linux-dev-env/linux/arch/x86/include -I/linux-dev-env/linux/arch/x86/include/generated -I/linux-dev-env/linux/include -I/linux-dev-env/linux/include -I/linux-dev-env/linux/arch/x86/include/uapi -I/linux-dev-env/linux/arch/x86/include/generated/uapi -I/linux-dev-env/linux/include/uapi -I/linux-dev-env/linux/include/generated/uapi -include /linux-dev-env/linux/include/linux/compiler-version.h -include /linux-dev-env/linux/include/linux/kconfig.h -include /linux-dev-env/linux/include/linux/compiler_types.h -D__KERNEL__ -std=gnu11 -fshort-wchar -funsigned-char -fno-common -fno-PIE -fno-strict-aliasing -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx -fcf-protection=branch -fno-jump-tables -m64 -falign-jumps=1 -falign-loops=1 -mno-80387 -mno-fp-ret-in-387 -mpreferred-stack-boundary=3 -mskip-rax-setup -mtune=generic -mno-red-zone -mcmodel=kernel -Wno-sign-compare -fno-asynchronous-unwind-tables -mindirect-branch=thunk-extern -mindirect-branch-register -mindirect-branch-cs-prefix -mfunction-return=thunk-extern -fno-jump-tables -fpatchable-function-entry=16,16 -fno-delete-null-pointer-checks -O2 -fno-allow-store-data-races -fstack-protector-strong -fomit-frame-pointer -fno-stack-clash-protection -falign-functions=16 -fstrict-flex-arrays=3 -fno-strict-overflow -fno-stack-check -fconserve-stack -Wall -Wundef -Werror=implicit-function-declaration -Werror=implicit-int -Werror=return-type -Werror=strict-prototypes -Wno-format-security -Wno-trigraphs -Wno-frame-address -Wno-address-of-packed-member -Wmissing-declarations -Wmissing-prototypes -Wframe-larger-than=2048 -Wno-main -Wno-dangling-pointer -Wvla -Wno-pointer-sign -Wcast-function-type -Wno-stringop-overflow -Wno-array-bounds -Wno-alloc-size-larger-than -Wimplicit-fallthrough=5 -Werror=date-time -Werror=incompatible-pointer-types -Werror=designated-init -Wenum-conversion -Wextra -Wunused -Wno-unused-but-set-variable -Wno-unused-const-variable -Wno-packed-not-aligned -Wno-format-overflow -Wno-format-truncation -Wno-stringop-truncation -Wno-override-init -Wno-missing-field-initializers -Wno-type-limits -Wno-shift-negative-value -Wno-maybe-uninitialized -Wno-sign-compare -Wno-unused-parameter -g -g -O2  -DMODULE  -DKBUILD_BASENAME='"reg_kfunc"' -DKBUILD_MODNAME='"reg_kfunc"' -D__KBUILD_MODNAME=kmod_reg_kfunc -c -o reg_kfunc.o reg_kfunc.c   ; /linux-dev-env/linux/tools/objtool/objtool --hacks=jump_label --hacks=noinstr --hacks=skylake --ibt --orc --retpoline --rethunk --static-call --uaccess --prefix=16  --link  --module reg_kfunc.o

source_reg_kfunc.o := reg_kfunc.c

deps_reg_kfunc.o := \
  /linux-dev-env/linux/include/linux/compiler-version.h \
    $(wildcard include/config/CC_VERSION_TEXT) \
  /linux-dev-env/linux/include/linux/kconfig.h \
    $(wildcard include/config/CPU_BIG_ENDIAN) \
    $(wildcard include/config/BOOGER) \
    $(wildcard include/config/FOO) \
  /linux-dev-env/linux/include/linux/compiler_types.h \
    $(wildcard include/config/DEBUG_INFO_BTF) \
    $(wildcard include/config/PAHOLE_HAS_BTF_TAG) \
    $(wildcard include/config/FUNCTION_ALIGNMENT) \
    $(wildcard include/config/CC_HAS_SANE_FUNCTION_ALIGNMENT) \
    $(wildcard include/config/X86_64) \
    $(wildcard include/config/ARM64) \
    $(wildcard include/config/LD_DEAD_CODE_DATA_ELIMINATION) \
    $(wildcard include/config/LTO_CLANG) \
    $(wildcard include/config/HAVE_ARCH_COMPILER_H) \
    $(wildcard include/config/CC_HAS_COUNTED_BY) \
    $(wildcard include/config/UBSAN_SIGNED_WRAP) \
    $(wildcard include/config/CC_HAS_ASM_INLINE) \
  /linux-dev-env/linux/include/linux/compiler_attributes.h \
  /linux-dev-env/linux/include/linux/compiler-gcc.h \
    $(wildcard include/config/MITIGATION_RETPOLINE) \
    $(wildcard include/config/ARCH_USE_BUILTIN_BSWAP) \
    $(wildcard include/config/SHADOW_CALL_STACK) \
    $(wildcard include/config/KCOV) \
  /linux-dev-env/linux/include/linux/init.h \
    $(wildcard include/config/MEMORY_HOTPLUG) \
    $(wildcard include/config/HAVE_ARCH_PREL32_RELOCATIONS) \
  /linux-dev-env/linux/include/linux/build_bug.h \
  /linux-dev-env/linux/include/linux/compiler.h \
    $(wildcard include/config/TRACE_BRANCH_PROFILING) \
    $(wildcard include/config/PROFILE_ALL_BRANCHES) \
    $(wildcard include/config/OBJTOOL) \
    $(wildcard include/config/64BIT) \
  /linux-dev-env/linux/arch/x86/include/generated/asm/rwonce.h \
  /linux-dev-env/linux/include/asm-generic/rwonce.h \
  /linux-dev-env/linux/include/linux/kasan-checks.h \
    $(wildcard include/config/KASAN_GENERIC) \
    $(wildcard include/config/KASAN_SW_TAGS) \
  /linux-dev-env/linux/include/linux/types.h \
    $(wildcard include/config/HAVE_UID16) \
    $(wildcard include/config/UID16) \
    $(wildcard include/config/ARCH_DMA_ADDR_T_64BIT) \
    $(wildcard include/config/PHYS_ADDR_T_64BIT) \
    $(wildcard include/config/ARCH_32BIT_USTAT_F_TINODE) \
  /linux-dev-env/linux/include/uapi/linux/types.h \
  /linux-dev-env/linux/arch/x86/include/generated/uapi/asm/types.h \
  /linux-dev-env/linux/include/uapi/asm-generic/types.h \
  /linux-dev-env/linux/include/asm-generic/int-ll64.h \
  /linux-dev-env/linux/include/uapi/asm-generic/int-ll64.h \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/bitsperlong.h \
  /linux-dev-env/linux/include/asm-generic/bitsperlong.h \
  /linux-dev-env/linux/include/uapi/asm-generic/bitsperlong.h \
  /linux-dev-env/linux/include/uapi/linux/posix_types.h \
  /linux-dev-env/linux/include/linux/stddef.h \
  /linux-dev-env/linux/include/uapi/linux/stddef.h \
  /linux-dev-env/linux/arch/x86/include/asm/posix_types.h \
    $(wildcard include/config/X86_32) \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/posix_types_64.h \
  /linux-dev-env/linux/include/uapi/asm-generic/posix_types.h \
  /linux-dev-env/linux/include/linux/kcsan-checks.h \
    $(wildcard include/config/KCSAN) \
    $(wildcard include/config/KCSAN_WEAK_MEMORY) \
    $(wildcard include/config/KCSAN_IGNORE_ATOMICS) \
  /linux-dev-env/linux/include/linux/stringify.h \
  /linux-dev-env/linux/include/linux/module.h \
    $(wildcard include/config/MODULES) \
    $(wildcard include/config/SYSFS) \
    $(wildcard include/config/MODULES_TREE_LOOKUP) \
    $(wildcard include/config/LIVEPATCH) \
    $(wildcard include/config/STACKTRACE_BUILD_ID) \
    $(wildcard include/config/ARCH_USES_CFI_TRAPS) \
    $(wildcard include/config/MODULE_SIG) \
    $(wildcard include/config/GENERIC_BUG) \
    $(wildcard include/config/KALLSYMS) \
    $(wildcard include/config/SMP) \
    $(wildcard include/config/TRACEPOINTS) \
    $(wildcard include/config/TREE_SRCU) \
    $(wildcard include/config/BPF_EVENTS) \
    $(wildcard include/config/DEBUG_INFO_BTF_MODULES) \
    $(wildcard include/config/JUMP_LABEL) \
    $(wildcard include/config/TRACING) \
    $(wildcard include/config/EVENT_TRACING) \
    $(wildcard include/config/FTRACE_MCOUNT_RECORD) \
    $(wildcard include/config/KPROBES) \
    $(wildcard include/config/HAVE_STATIC_CALL_INLINE) \
    $(wildcard include/config/KUNIT) \
    $(wildcard include/config/PRINTK_INDEX) \
    $(wildcard include/config/MODULE_UNLOAD) \
    $(wildcard include/config/CONSTRUCTORS) \
    $(wildcard include/config/FUNCTION_ERROR_INJECTION) \
    $(wildcard include/config/DYNAMIC_DEBUG_CORE) \
    $(wildcard include/config/ARCH_HAS_EXECMEM_ROX) \
  /linux-dev-env/linux/include/linux/list.h \
    $(wildcard include/config/LIST_HARDENED) \
    $(wildcard include/config/DEBUG_LIST) \
  /linux-dev-env/linux/include/linux/container_of.h \
  /linux-dev-env/linux/include/linux/poison.h \
    $(wildcard include/config/ILLEGAL_POINTER_VALUE) \
  /linux-dev-env/linux/include/linux/const.h \
  /linux-dev-env/linux/include/vdso/const.h \
  /linux-dev-env/linux/include/uapi/linux/const.h \
  /linux-dev-env/linux/arch/x86/include/asm/barrier.h \
  /linux-dev-env/linux/arch/x86/include/asm/alternative.h \
    $(wildcard include/config/CALL_THUNKS) \
  /linux-dev-env/linux/arch/x86/include/asm/asm.h \
  /linux-dev-env/linux/arch/x86/include/asm/extable_fixup_types.h \
  /linux-dev-env/linux/arch/x86/include/asm/nops.h \
  /linux-dev-env/linux/include/asm-generic/barrier.h \
  /linux-dev-env/linux/include/linux/stat.h \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/stat.h \
  /linux-dev-env/linux/include/uapi/linux/stat.h \
  /linux-dev-env/linux/include/linux/time.h \
    $(wildcard include/config/POSIX_TIMERS) \
  /linux-dev-env/linux/include/linux/cache.h \
    $(wildcard include/config/ARCH_HAS_CACHE_LINE_SIZE) \
  /linux-dev-env/linux/include/uapi/linux/kernel.h \
  /linux-dev-env/linux/include/uapi/linux/sysinfo.h \
  /linux-dev-env/linux/arch/x86/include/asm/cache.h \
    $(wildcard include/config/X86_L1_CACHE_SHIFT) \
    $(wildcard include/config/X86_INTERNODE_CACHE_SHIFT) \
    $(wildcard include/config/X86_VSMP) \
  /linux-dev-env/linux/include/linux/linkage.h \
    $(wildcard include/config/ARCH_USE_SYM_ANNOTATIONS) \
  /linux-dev-env/linux/include/linux/export.h \
    $(wildcard include/config/MODVERSIONS) \
  /linux-dev-env/linux/arch/x86/include/asm/linkage.h \
    $(wildcard include/config/CALL_PADDING) \
    $(wildcard include/config/MITIGATION_RETHUNK) \
    $(wildcard include/config/MITIGATION_SLS) \
    $(wildcard include/config/FUNCTION_PADDING_BYTES) \
    $(wildcard include/config/UML) \
  /linux-dev-env/linux/arch/x86/include/asm/ibt.h \
    $(wildcard include/config/X86_KERNEL_IBT) \
  /linux-dev-env/linux/include/linux/math64.h \
    $(wildcard include/config/ARCH_SUPPORTS_INT128) \
  /linux-dev-env/linux/include/linux/math.h \
  /linux-dev-env/linux/arch/x86/include/asm/div64.h \
  /linux-dev-env/linux/include/asm-generic/div64.h \
    $(wildcard include/config/CC_OPTIMIZE_FOR_PERFORMANCE) \
  /linux-dev-env/linux/include/vdso/math64.h \
  /linux-dev-env/linux/include/linux/time64.h \
  /linux-dev-env/linux/include/vdso/time64.h \
  /linux-dev-env/linux/include/uapi/linux/time.h \
  /linux-dev-env/linux/include/uapi/linux/time_types.h \
  /linux-dev-env/linux/include/linux/time32.h \
  /linux-dev-env/linux/include/linux/timex.h \
  /linux-dev-env/linux/include/uapi/linux/timex.h \
  /linux-dev-env/linux/include/uapi/linux/param.h \
  /linux-dev-env/linux/arch/x86/include/generated/uapi/asm/param.h \
  /linux-dev-env/linux/include/asm-generic/param.h \
    $(wildcard include/config/HZ) \
  /linux-dev-env/linux/include/uapi/asm-generic/param.h \
  /linux-dev-env/linux/arch/x86/include/asm/timex.h \
    $(wildcard include/config/X86_TSC) \
  /linux-dev-env/linux/arch/x86/include/asm/processor.h \
    $(wildcard include/config/X86_VMX_FEATURE_NAMES) \
    $(wildcard include/config/X86_IOPL_IOPERM) \
    $(wildcard include/config/STACKPROTECTOR) \
    $(wildcard include/config/VM86) \
    $(wildcard include/config/X86_USER_SHADOW_STACK) \
    $(wildcard include/config/USE_X86_SEG_SUPPORT) \
    $(wildcard include/config/PARAVIRT_XXL) \
    $(wildcard include/config/CPU_SUP_AMD) \
    $(wildcard include/config/XEN) \
  /linux-dev-env/linux/arch/x86/include/asm/processor-flags.h \
    $(wildcard include/config/MITIGATION_PAGE_TABLE_ISOLATION) \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/processor-flags.h \
  /linux-dev-env/linux/include/linux/mem_encrypt.h \
    $(wildcard include/config/ARCH_HAS_MEM_ENCRYPT) \
    $(wildcard include/config/AMD_MEM_ENCRYPT) \
  /linux-dev-env/linux/arch/x86/include/asm/mem_encrypt.h \
    $(wildcard include/config/X86_MEM_ENCRYPT) \
  /linux-dev-env/linux/include/linux/cc_platform.h \
    $(wildcard include/config/ARCH_HAS_CC_PLATFORM) \
  /linux-dev-env/linux/arch/x86/include/asm/math_emu.h \
  /linux-dev-env/linux/arch/x86/include/asm/ptrace.h \
    $(wildcard include/config/PARAVIRT) \
    $(wildcard include/config/IA32_EMULATION) \
    $(wildcard include/config/X86_DEBUGCTLMSR) \
  /linux-dev-env/linux/arch/x86/include/asm/segment.h \
    $(wildcard include/config/XEN_PV) \
  /linux-dev-env/linux/arch/x86/include/asm/page_types.h \
    $(wildcard include/config/PHYSICAL_START) \
    $(wildcard include/config/PHYSICAL_ALIGN) \
    $(wildcard include/config/DYNAMIC_PHYSICAL_MASK) \
  /linux-dev-env/linux/include/vdso/page.h \
    $(wildcard include/config/PAGE_SHIFT) \
  /linux-dev-env/linux/arch/x86/include/asm/page_64_types.h \
    $(wildcard include/config/KASAN) \
    $(wildcard include/config/DYNAMIC_MEMORY_LAYOUT) \
    $(wildcard include/config/X86_5LEVEL) \
    $(wildcard include/config/RANDOMIZE_BASE) \
  /linux-dev-env/linux/arch/x86/include/asm/kaslr.h \
    $(wildcard include/config/RANDOMIZE_MEMORY) \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/ptrace.h \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/ptrace-abi.h \
  /linux-dev-env/linux/arch/x86/include/asm/paravirt_types.h \
    $(wildcard include/config/PGTABLE_LEVELS) \
    $(wildcard include/config/ZERO_CALL_USED_REGS) \
    $(wildcard include/config/PARAVIRT_DEBUG) \
  /linux-dev-env/linux/arch/x86/include/asm/desc_defs.h \
  /linux-dev-env/linux/arch/x86/include/asm/pgtable_types.h \
    $(wildcard include/config/X86_INTEL_MEMORY_PROTECTION_KEYS) \
    $(wildcard include/config/X86_PAE) \
    $(wildcard include/config/MEM_SOFT_DIRTY) \
    $(wildcard include/config/HAVE_ARCH_USERFAULTFD_WP) \
    $(wildcard include/config/PROC_FS) \
  /linux-dev-env/linux/arch/x86/include/asm/pgtable_64_types.h \
    $(wildcard include/config/KMSAN) \
    $(wildcard include/config/DEBUG_KMAP_LOCAL_FORCE_MAP) \
  /linux-dev-env/linux/arch/x86/include/asm/sparsemem.h \
    $(wildcard include/config/SPARSEMEM) \
  /linux-dev-env/linux/arch/x86/include/asm/nospec-branch.h \
    $(wildcard include/config/CALL_THUNKS_DEBUG) \
    $(wildcard include/config/MITIGATION_CALL_DEPTH_TRACKING) \
    $(wildcard include/config/NOINSTR_VALIDATION) \
    $(wildcard include/config/MITIGATION_UNRET_ENTRY) \
    $(wildcard include/config/MITIGATION_SRSO) \
    $(wildcard include/config/MITIGATION_IBPB_ENTRY) \
  /linux-dev-env/linux/include/linux/static_key.h \
  /linux-dev-env/linux/include/linux/jump_label.h \
    $(wildcard include/config/HAVE_ARCH_JUMP_LABEL_RELATIVE) \
  /linux-dev-env/linux/arch/x86/include/asm/jump_label.h \
    $(wildcard include/config/HAVE_JUMP_LABEL_HACK) \
  /linux-dev-env/linux/include/linux/objtool.h \
    $(wildcard include/config/FRAME_POINTER) \
  /linux-dev-env/linux/include/linux/objtool_types.h \
  /linux-dev-env/linux/arch/x86/include/asm/cpufeatures.h \
  /linux-dev-env/linux/arch/x86/include/asm/required-features.h \
    $(wildcard include/config/X86_MINIMUM_CPU_FAMILY) \
    $(wildcard include/config/MATH_EMULATION) \
    $(wildcard include/config/X86_CMPXCHG64) \
    $(wildcard include/config/X86_CMOV) \
    $(wildcard include/config/X86_P6_NOP) \
    $(wildcard include/config/MATOM) \
  /linux-dev-env/linux/arch/x86/include/asm/disabled-features.h \
    $(wildcard include/config/X86_UMIP) \
    $(wildcard include/config/ADDRESS_MASKING) \
    $(wildcard include/config/INTEL_IOMMU_SVM) \
    $(wildcard include/config/X86_SGX) \
    $(wildcard include/config/INTEL_TDX_GUEST) \
    $(wildcard include/config/X86_FRED) \
    $(wildcard include/config/KVM_AMD_SEV) \
  /linux-dev-env/linux/arch/x86/include/asm/msr-index.h \
  /linux-dev-env/linux/include/linux/bits.h \
  /linux-dev-env/linux/include/vdso/bits.h \
  /linux-dev-env/linux/include/uapi/linux/bits.h \
  /linux-dev-env/linux/arch/x86/include/asm/unwind_hints.h \
  /linux-dev-env/linux/arch/x86/include/asm/orc_types.h \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/byteorder.h \
  /linux-dev-env/linux/include/linux/byteorder/little_endian.h \
  /linux-dev-env/linux/include/uapi/linux/byteorder/little_endian.h \
  /linux-dev-env/linux/include/linux/swab.h \
  /linux-dev-env/linux/include/uapi/linux/swab.h \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/swab.h \
  /linux-dev-env/linux/include/linux/byteorder/generic.h \
  /linux-dev-env/linux/arch/x86/include/asm/percpu.h \
    $(wildcard include/config/X86_64_SMP) \
    $(wildcard include/config/CC_HAS_NAMED_AS) \
  /linux-dev-env/linux/include/asm-generic/percpu.h \
    $(wildcard include/config/DEBUG_PREEMPT) \
    $(wildcard include/config/HAVE_SETUP_PER_CPU_AREA) \
  /linux-dev-env/linux/include/linux/threads.h \
    $(wildcard include/config/NR_CPUS) \
    $(wildcard include/config/BASE_SMALL) \
  /linux-dev-env/linux/include/linux/percpu-defs.h \
    $(wildcard include/config/DEBUG_FORCE_WEAK_PER_CPU) \
  /linux-dev-env/linux/arch/x86/include/asm/current.h \
  /linux-dev-env/linux/arch/x86/include/asm/asm-offsets.h \
  /linux-dev-env/linux/include/generated/asm-offsets.h \
  /linux-dev-env/linux/arch/x86/include/asm/GEN-for-each-reg.h \
  /linux-dev-env/linux/arch/x86/include/asm/spinlock_types.h \
  /linux-dev-env/linux/include/asm-generic/qspinlock_types.h \
  /linux-dev-env/linux/include/asm-generic/qrwlock_types.h \
  /linux-dev-env/linux/arch/x86/include/asm/proto.h \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/ldt.h \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/sigcontext.h \
  /linux-dev-env/linux/arch/x86/include/asm/cpuid.h \
  /linux-dev-env/linux/arch/x86/include/asm/string.h \
  /linux-dev-env/linux/arch/x86/include/asm/string_64.h \
    $(wildcard include/config/ARCH_HAS_UACCESS_FLUSHCACHE) \
  /linux-dev-env/linux/arch/x86/include/asm/page.h \
  /linux-dev-env/linux/arch/x86/include/asm/page_64.h \
    $(wildcard include/config/DEBUG_VIRTUAL) \
    $(wildcard include/config/X86_VSYSCALL_EMULATION) \
  /linux-dev-env/linux/include/linux/kmsan-checks.h \
  /linux-dev-env/linux/include/linux/range.h \
  /linux-dev-env/linux/include/asm-generic/memory_model.h \
    $(wildcard include/config/FLATMEM) \
    $(wildcard include/config/SPARSEMEM_VMEMMAP) \
  /linux-dev-env/linux/include/linux/pfn.h \
  /linux-dev-env/linux/include/asm-generic/getorder.h \
  /linux-dev-env/linux/include/linux/log2.h \
    $(wildcard include/config/ARCH_HAS_ILOG2_U32) \
    $(wildcard include/config/ARCH_HAS_ILOG2_U64) \
  /linux-dev-env/linux/include/linux/bitops.h \
  /linux-dev-env/linux/include/linux/typecheck.h \
  /linux-dev-env/linux/include/asm-generic/bitops/generic-non-atomic.h \
  /linux-dev-env/linux/arch/x86/include/asm/bitops.h \
  /linux-dev-env/linux/arch/x86/include/asm/rmwcc.h \
  /linux-dev-env/linux/include/linux/args.h \
  /linux-dev-env/linux/include/asm-generic/bitops/sched.h \
  /linux-dev-env/linux/arch/x86/include/asm/arch_hweight.h \
  /linux-dev-env/linux/include/asm-generic/bitops/const_hweight.h \
  /linux-dev-env/linux/include/asm-generic/bitops/instrumented-atomic.h \
  /linux-dev-env/linux/include/linux/instrumented.h \
  /linux-dev-env/linux/include/asm-generic/bitops/instrumented-non-atomic.h \
    $(wildcard include/config/KCSAN_ASSUME_PLAIN_WRITES_ATOMIC) \
  /linux-dev-env/linux/include/asm-generic/bitops/instrumented-lock.h \
  /linux-dev-env/linux/include/asm-generic/bitops/le.h \
  /linux-dev-env/linux/include/asm-generic/bitops/ext2-atomic-setbit.h \
  /linux-dev-env/linux/arch/x86/include/asm/special_insns.h \
  /linux-dev-env/linux/include/linux/errno.h \
  /linux-dev-env/linux/include/uapi/linux/errno.h \
  /linux-dev-env/linux/arch/x86/include/generated/uapi/asm/errno.h \
  /linux-dev-env/linux/include/uapi/asm-generic/errno.h \
  /linux-dev-env/linux/include/uapi/asm-generic/errno-base.h \
  /linux-dev-env/linux/include/linux/irqflags.h \
    $(wildcard include/config/PROVE_LOCKING) \
    $(wildcard include/config/TRACE_IRQFLAGS) \
    $(wildcard include/config/PREEMPT_RT) \
    $(wildcard include/config/IRQSOFF_TRACER) \
    $(wildcard include/config/PREEMPT_TRACER) \
    $(wildcard include/config/DEBUG_IRQFLAGS) \
    $(wildcard include/config/TRACE_IRQFLAGS_SUPPORT) \
  /linux-dev-env/linux/include/linux/irqflags_types.h \
  /linux-dev-env/linux/include/linux/cleanup.h \
  /linux-dev-env/linux/arch/x86/include/asm/irqflags.h \
    $(wildcard include/config/DEBUG_ENTRY) \
  /linux-dev-env/linux/arch/x86/include/asm/fpu/types.h \
  /linux-dev-env/linux/arch/x86/include/asm/vmxfeatures.h \
  /linux-dev-env/linux/arch/x86/include/asm/vdso/processor.h \
  /linux-dev-env/linux/arch/x86/include/asm/shstk.h \
  /linux-dev-env/linux/include/linux/personality.h \
  /linux-dev-env/linux/include/uapi/linux/personality.h \
  /linux-dev-env/linux/include/linux/err.h \
  /linux-dev-env/linux/arch/x86/include/asm/tsc.h \
  /linux-dev-env/linux/arch/x86/include/asm/cpufeature.h \
  /linux-dev-env/linux/arch/x86/include/asm/msr.h \
  /linux-dev-env/linux/arch/x86/include/asm/cpumask.h \
  /linux-dev-env/linux/include/linux/cpumask.h \
    $(wildcard include/config/FORCE_NR_CPUS) \
    $(wildcard include/config/HOTPLUG_CPU) \
    $(wildcard include/config/DEBUG_PER_CPU_MAPS) \
    $(wildcard include/config/CPUMASK_OFFSTACK) \
  /linux-dev-env/linux/include/linux/kernel.h \
    $(wildcard include/config/PREEMPT_VOLUNTARY_BUILD) \
    $(wildcard include/config/PREEMPT_DYNAMIC) \
    $(wildcard include/config/HAVE_PREEMPT_DYNAMIC_CALL) \
    $(wildcard include/config/HAVE_PREEMPT_DYNAMIC_KEY) \
    $(wildcard include/config/PREEMPT_) \
    $(wildcard include/config/DEBUG_ATOMIC_SLEEP) \
    $(wildcard include/config/MMU) \
  /linux-dev-env/linux/include/linux/stdarg.h \
  /linux-dev-env/linux/include/linux/align.h \
  /linux-dev-env/linux/include/linux/array_size.h \
  /linux-dev-env/linux/include/linux/limits.h \
  /linux-dev-env/linux/include/uapi/linux/limits.h \
  /linux-dev-env/linux/include/vdso/limits.h \
  /linux-dev-env/linux/include/linux/hex.h \
  /linux-dev-env/linux/include/linux/kstrtox.h \
  /linux-dev-env/linux/include/linux/minmax.h \
  /linux-dev-env/linux/include/linux/panic.h \
    $(wildcard include/config/PANIC_TIMEOUT) \
  /linux-dev-env/linux/include/linux/printk.h \
    $(wildcard include/config/MESSAGE_LOGLEVEL_DEFAULT) \
    $(wildcard include/config/CONSOLE_LOGLEVEL_DEFAULT) \
    $(wildcard include/config/CONSOLE_LOGLEVEL_QUIET) \
    $(wildcard include/config/EARLY_PRINTK) \
    $(wildcard include/config/PRINTK) \
    $(wildcard include/config/DYNAMIC_DEBUG) \
  /linux-dev-env/linux/include/linux/kern_levels.h \
  /linux-dev-env/linux/include/linux/ratelimit_types.h \
  /linux-dev-env/linux/include/linux/spinlock_types_raw.h \
    $(wildcard include/config/DEBUG_SPINLOCK) \
    $(wildcard include/config/DEBUG_LOCK_ALLOC) \
  /linux-dev-env/linux/include/linux/lockdep_types.h \
    $(wildcard include/config/PROVE_RAW_LOCK_NESTING) \
    $(wildcard include/config/LOCKDEP) \
    $(wildcard include/config/LOCK_STAT) \
  /linux-dev-env/linux/include/linux/once_lite.h \
  /linux-dev-env/linux/include/linux/sprintf.h \
  /linux-dev-env/linux/include/linux/static_call_types.h \
    $(wildcard include/config/HAVE_STATIC_CALL) \
  /linux-dev-env/linux/include/linux/instruction_pointer.h \
  /linux-dev-env/linux/include/linux/wordpart.h \
  /linux-dev-env/linux/include/linux/bitmap.h \
  /linux-dev-env/linux/include/linux/find.h \
  /linux-dev-env/linux/include/linux/string.h \
    $(wildcard include/config/BINARY_PRINTF) \
    $(wildcard include/config/FORTIFY_SOURCE) \
  /linux-dev-env/linux/include/linux/overflow.h \
  /linux-dev-env/linux/include/uapi/linux/string.h \
  /linux-dev-env/linux/include/linux/bitmap-str.h \
  /linux-dev-env/linux/include/linux/cpumask_types.h \
  /linux-dev-env/linux/include/linux/atomic.h \
  /linux-dev-env/linux/arch/x86/include/asm/atomic.h \
  /linux-dev-env/linux/arch/x86/include/asm/cmpxchg.h \
  /linux-dev-env/linux/arch/x86/include/asm/cmpxchg_64.h \
  /linux-dev-env/linux/arch/x86/include/asm/atomic64_64.h \
  /linux-dev-env/linux/include/linux/atomic/atomic-arch-fallback.h \
    $(wildcard include/config/GENERIC_ATOMIC64) \
  /linux-dev-env/linux/include/linux/atomic/atomic-long.h \
  /linux-dev-env/linux/include/linux/atomic/atomic-instrumented.h \
  /linux-dev-env/linux/include/linux/bug.h \
    $(wildcard include/config/BUG_ON_DATA_CORRUPTION) \
  /linux-dev-env/linux/arch/x86/include/asm/bug.h \
    $(wildcard include/config/DEBUG_BUGVERBOSE) \
  /linux-dev-env/linux/include/linux/instrumentation.h \
  /linux-dev-env/linux/include/asm-generic/bug.h \
    $(wildcard include/config/BUG) \
    $(wildcard include/config/GENERIC_BUG_RELATIVE_POINTERS) \
  /linux-dev-env/linux/include/linux/gfp_types.h \
    $(wildcard include/config/KASAN_HW_TAGS) \
    $(wildcard include/config/SLAB_OBJ_EXT) \
  /linux-dev-env/linux/include/linux/numa.h \
    $(wildcard include/config/NODES_SHIFT) \
    $(wildcard include/config/NUMA_KEEP_MEMINFO) \
    $(wildcard include/config/NUMA) \
    $(wildcard include/config/HAVE_ARCH_NODE_DEV_GROUP) \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/msr.h \
  /linux-dev-env/linux/include/uapi/linux/ioctl.h \
  /linux-dev-env/linux/arch/x86/include/generated/uapi/asm/ioctl.h \
  /linux-dev-env/linux/include/asm-generic/ioctl.h \
  /linux-dev-env/linux/include/uapi/asm-generic/ioctl.h \
  /linux-dev-env/linux/arch/x86/include/asm/shared/msr.h \
  /linux-dev-env/linux/include/linux/percpu.h \
    $(wildcard include/config/MEM_ALLOC_PROFILING) \
    $(wildcard include/config/RANDOM_KMALLOC_CACHES) \
    $(wildcard include/config/PAGE_SIZE_4KB) \
    $(wildcard include/config/NEED_PER_CPU_PAGE_FIRST_CHUNK) \
  /linux-dev-env/linux/include/linux/alloc_tag.h \
    $(wildcard include/config/MEM_ALLOC_PROFILING_DEBUG) \
    $(wildcard include/config/MEM_ALLOC_PROFILING_ENABLED_BY_DEFAULT) \
  /linux-dev-env/linux/include/linux/codetag.h \
    $(wildcard include/config/CODE_TAGGING) \
  /linux-dev-env/linux/include/linux/preempt.h \
    $(wildcard include/config/PREEMPT_COUNT) \
    $(wildcard include/config/TRACE_PREEMPT_TOGGLE) \
    $(wildcard include/config/PREEMPTION) \
    $(wildcard include/config/PREEMPT_NOTIFIERS) \
    $(wildcard include/config/PREEMPT_NONE) \
    $(wildcard include/config/PREEMPT_VOLUNTARY) \
    $(wildcard include/config/PREEMPT) \
    $(wildcard include/config/PREEMPT_LAZY) \
  /linux-dev-env/linux/arch/x86/include/asm/preempt.h \
  /linux-dev-env/linux/include/linux/smp.h \
    $(wildcard include/config/UP_LATE_INIT) \
    $(wildcard include/config/CSD_LOCK_WAIT_DEBUG) \
  /linux-dev-env/linux/include/linux/smp_types.h \
  /linux-dev-env/linux/include/linux/llist.h \
    $(wildcard include/config/ARCH_HAVE_NMI_SAFE_CMPXCHG) \
  /linux-dev-env/linux/include/linux/thread_info.h \
    $(wildcard include/config/THREAD_INFO_IN_TASK) \
    $(wildcard include/config/GENERIC_ENTRY) \
    $(wildcard include/config/ARCH_HAS_PREEMPT_LAZY) \
    $(wildcard include/config/HAVE_ARCH_WITHIN_STACK_FRAMES) \
    $(wildcard include/config/HARDENED_USERCOPY) \
    $(wildcard include/config/SH) \
  /linux-dev-env/linux/include/linux/restart_block.h \
  /linux-dev-env/linux/arch/x86/include/asm/thread_info.h \
    $(wildcard include/config/COMPAT) \
  /linux-dev-env/linux/arch/x86/include/asm/smp.h \
    $(wildcard include/config/DEBUG_NMI_SELFTEST) \
  /linux-dev-env/linux/include/linux/mmdebug.h \
    $(wildcard include/config/DEBUG_VM) \
    $(wildcard include/config/DEBUG_VM_IRQSOFF) \
    $(wildcard include/config/DEBUG_VM_PGFLAGS) \
  /linux-dev-env/linux/include/linux/sched.h \
    $(wildcard include/config/VIRT_CPU_ACCOUNTING_NATIVE) \
    $(wildcard include/config/SCHED_INFO) \
    $(wildcard include/config/SCHEDSTATS) \
    $(wildcard include/config/SCHED_CORE) \
    $(wildcard include/config/FAIR_GROUP_SCHED) \
    $(wildcard include/config/RT_GROUP_SCHED) \
    $(wildcard include/config/RT_MUTEXES) \
    $(wildcard include/config/UCLAMP_TASK) \
    $(wildcard include/config/UCLAMP_BUCKETS_COUNT) \
    $(wildcard include/config/KMAP_LOCAL) \
    $(wildcard include/config/SCHED_CLASS_EXT) \
    $(wildcard include/config/CGROUP_SCHED) \
    $(wildcard include/config/BLK_DEV_IO_TRACE) \
    $(wildcard include/config/PREEMPT_RCU) \
    $(wildcard include/config/TASKS_RCU) \
    $(wildcard include/config/TASKS_TRACE_RCU) \
    $(wildcard include/config/MEMCG_V1) \
    $(wildcard include/config/LRU_GEN) \
    $(wildcard include/config/COMPAT_BRK) \
    $(wildcard include/config/CGROUPS) \
    $(wildcard include/config/BLK_CGROUP) \
    $(wildcard include/config/PSI) \
    $(wildcard include/config/PAGE_OWNER) \
    $(wildcard include/config/EVENTFD) \
    $(wildcard include/config/ARCH_HAS_CPU_PASID) \
    $(wildcard include/config/X86_BUS_LOCK_DETECT) \
    $(wildcard include/config/TASK_DELAY_ACCT) \
    $(wildcard include/config/ARCH_HAS_SCALED_CPUTIME) \
    $(wildcard include/config/VIRT_CPU_ACCOUNTING_GEN) \
    $(wildcard include/config/NO_HZ_FULL) \
    $(wildcard include/config/POSIX_CPUTIMERS) \
    $(wildcard include/config/POSIX_CPU_TIMERS_TASK_WORK) \
    $(wildcard include/config/KEYS) \
    $(wildcard include/config/SYSVIPC) \
    $(wildcard include/config/DETECT_HUNG_TASK) \
    $(wildcard include/config/IO_URING) \
    $(wildcard include/config/AUDIT) \
    $(wildcard include/config/AUDITSYSCALL) \
    $(wildcard include/config/DEBUG_MUTEXES) \
    $(wildcard include/config/UBSAN) \
    $(wildcard include/config/UBSAN_TRAP) \
    $(wildcard include/config/COMPACTION) \
    $(wildcard include/config/TASK_XACCT) \
    $(wildcard include/config/CPUSETS) \
    $(wildcard include/config/X86_CPU_RESCTRL) \
    $(wildcard include/config/FUTEX) \
    $(wildcard include/config/PERF_EVENTS) \
    $(wildcard include/config/NUMA_BALANCING) \
    $(wildcard include/config/RSEQ) \
    $(wildcard include/config/SCHED_MM_CID) \
    $(wildcard include/config/FAULT_INJECTION) \
    $(wildcard include/config/LATENCYTOP) \
    $(wildcard include/config/FUNCTION_GRAPH_TRACER) \
    $(wildcard include/config/MEMCG) \
    $(wildcard include/config/UPROBES) \
    $(wildcard include/config/BCACHE) \
    $(wildcard include/config/VMAP_STACK) \
    $(wildcard include/config/SECURITY) \
    $(wildcard include/config/BPF_SYSCALL) \
    $(wildcard include/config/GCC_PLUGIN_STACKLEAK) \
    $(wildcard include/config/X86_MCE) \
    $(wildcard include/config/KRETPROBES) \
    $(wildcard include/config/RETHOOK) \
    $(wildcard include/config/ARCH_HAS_PARANOID_L1D_FLUSH) \
    $(wildcard include/config/RV) \
    $(wildcard include/config/USER_EVENTS) \
  /linux-dev-env/linux/include/uapi/linux/sched.h \
  /linux-dev-env/linux/include/linux/pid_types.h \
  /linux-dev-env/linux/include/linux/sem_types.h \
  /linux-dev-env/linux/include/linux/shm.h \
  /linux-dev-env/linux/arch/x86/include/asm/shmparam.h \
  /linux-dev-env/linux/include/linux/kmsan_types.h \
  /linux-dev-env/linux/include/linux/mutex_types.h \
    $(wildcard include/config/MUTEX_SPIN_ON_OWNER) \
  /linux-dev-env/linux/include/linux/osq_lock.h \
  /linux-dev-env/linux/include/linux/spinlock_types.h \
  /linux-dev-env/linux/include/linux/rwlock_types.h \
  /linux-dev-env/linux/include/linux/plist_types.h \
  /linux-dev-env/linux/include/linux/hrtimer_types.h \
  /linux-dev-env/linux/include/linux/timerqueue_types.h \
  /linux-dev-env/linux/include/linux/rbtree_types.h \
  /linux-dev-env/linux/include/linux/timer_types.h \
  /linux-dev-env/linux/include/linux/seccomp_types.h \
    $(wildcard include/config/SECCOMP) \
  /linux-dev-env/linux/include/linux/nodemask_types.h \
  /linux-dev-env/linux/include/linux/refcount_types.h \
  /linux-dev-env/linux/include/linux/resource.h \
  /linux-dev-env/linux/include/uapi/linux/resource.h \
  /linux-dev-env/linux/arch/x86/include/generated/uapi/asm/resource.h \
  /linux-dev-env/linux/include/asm-generic/resource.h \
  /linux-dev-env/linux/include/uapi/asm-generic/resource.h \
  /linux-dev-env/linux/include/linux/latencytop.h \
  /linux-dev-env/linux/include/linux/sched/prio.h \
  /linux-dev-env/linux/include/linux/sched/types.h \
  /linux-dev-env/linux/include/linux/signal_types.h \
    $(wildcard include/config/OLD_SIGACTION) \
  /linux-dev-env/linux/include/uapi/linux/signal.h \
  /linux-dev-env/linux/arch/x86/include/asm/signal.h \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/signal.h \
  /linux-dev-env/linux/include/uapi/asm-generic/signal-defs.h \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/siginfo.h \
  /linux-dev-env/linux/include/uapi/asm-generic/siginfo.h \
  /linux-dev-env/linux/include/linux/syscall_user_dispatch_types.h \
  /linux-dev-env/linux/include/linux/mm_types_task.h \
    $(wildcard include/config/ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH) \
  /linux-dev-env/linux/arch/x86/include/asm/tlbbatch.h \
  /linux-dev-env/linux/include/linux/netdevice_xmit.h \
    $(wildcard include/config/NET_EGRESS) \
  /linux-dev-env/linux/include/linux/task_io_accounting.h \
    $(wildcard include/config/TASK_IO_ACCOUNTING) \
  /linux-dev-env/linux/include/linux/posix-timers_types.h \
  /linux-dev-env/linux/include/uapi/linux/rseq.h \
  /linux-dev-env/linux/include/linux/seqlock_types.h \
  /linux-dev-env/linux/include/linux/kcsan.h \
  /linux-dev-env/linux/include/linux/rv.h \
    $(wildcard include/config/RV_REACTORS) \
  /linux-dev-env/linux/include/linux/livepatch_sched.h \
  /linux-dev-env/linux/include/linux/uidgid_types.h \
  /linux-dev-env/linux/arch/x86/include/generated/asm/kmap_size.h \
  /linux-dev-env/linux/include/asm-generic/kmap_size.h \
    $(wildcard include/config/DEBUG_KMAP_LOCAL) \
  /linux-dev-env/linux/include/linux/sched/ext.h \
    $(wildcard include/config/EXT_GROUP_SCHED) \
  /linux-dev-env/linux/include/linux/spinlock.h \
  /linux-dev-env/linux/include/linux/bottom_half.h \
  /linux-dev-env/linux/include/linux/lockdep.h \
    $(wildcard include/config/DEBUG_LOCKING_API_SELFTESTS) \
  /linux-dev-env/linux/arch/x86/include/generated/asm/mmiowb.h \
  /linux-dev-env/linux/include/asm-generic/mmiowb.h \
    $(wildcard include/config/MMIOWB) \
  /linux-dev-env/linux/arch/x86/include/asm/spinlock.h \
  /linux-dev-env/linux/arch/x86/include/asm/paravirt.h \
    $(wildcard include/config/PARAVIRT_SPINLOCKS) \
  /linux-dev-env/linux/arch/x86/include/asm/frame.h \
  /linux-dev-env/linux/arch/x86/include/asm/qspinlock.h \
  /linux-dev-env/linux/include/asm-generic/qspinlock.h \
  /linux-dev-env/linux/arch/x86/include/asm/qrwlock.h \
  /linux-dev-env/linux/include/asm-generic/qrwlock.h \
  /linux-dev-env/linux/include/linux/rwlock.h \
  /linux-dev-env/linux/include/linux/spinlock_api_smp.h \
    $(wildcard include/config/INLINE_SPIN_LOCK) \
    $(wildcard include/config/INLINE_SPIN_LOCK_BH) \
    $(wildcard include/config/INLINE_SPIN_LOCK_IRQ) \
    $(wildcard include/config/INLINE_SPIN_LOCK_IRQSAVE) \
    $(wildcard include/config/INLINE_SPIN_TRYLOCK) \
    $(wildcard include/config/INLINE_SPIN_TRYLOCK_BH) \
    $(wildcard include/config/UNINLINE_SPIN_UNLOCK) \
    $(wildcard include/config/INLINE_SPIN_UNLOCK_BH) \
    $(wildcard include/config/INLINE_SPIN_UNLOCK_IRQ) \
    $(wildcard include/config/INLINE_SPIN_UNLOCK_IRQRESTORE) \
    $(wildcard include/config/GENERIC_LOCKBREAK) \
  /linux-dev-env/linux/include/linux/rwlock_api_smp.h \
    $(wildcard include/config/INLINE_READ_LOCK) \
    $(wildcard include/config/INLINE_WRITE_LOCK) \
    $(wildcard include/config/INLINE_READ_LOCK_BH) \
    $(wildcard include/config/INLINE_WRITE_LOCK_BH) \
    $(wildcard include/config/INLINE_READ_LOCK_IRQ) \
    $(wildcard include/config/INLINE_WRITE_LOCK_IRQ) \
    $(wildcard include/config/INLINE_READ_LOCK_IRQSAVE) \
    $(wildcard include/config/INLINE_WRITE_LOCK_IRQSAVE) \
    $(wildcard include/config/INLINE_READ_TRYLOCK) \
    $(wildcard include/config/INLINE_WRITE_TRYLOCK) \
    $(wildcard include/config/INLINE_READ_UNLOCK) \
    $(wildcard include/config/INLINE_WRITE_UNLOCK) \
    $(wildcard include/config/INLINE_READ_UNLOCK_BH) \
    $(wildcard include/config/INLINE_WRITE_UNLOCK_BH) \
    $(wildcard include/config/INLINE_READ_UNLOCK_IRQ) \
    $(wildcard include/config/INLINE_WRITE_UNLOCK_IRQ) \
    $(wildcard include/config/INLINE_READ_UNLOCK_IRQRESTORE) \
    $(wildcard include/config/INLINE_WRITE_UNLOCK_IRQRESTORE) \
  /linux-dev-env/linux/include/linux/tracepoint-defs.h \
  /linux-dev-env/linux/include/vdso/time32.h \
  /linux-dev-env/linux/include/vdso/time.h \
  /linux-dev-env/linux/include/linux/uidgid.h \
    $(wildcard include/config/MULTIUSER) \
    $(wildcard include/config/USER_NS) \
  /linux-dev-env/linux/include/linux/highuid.h \
  /linux-dev-env/linux/include/linux/buildid.h \
    $(wildcard include/config/VMCORE_INFO) \
  /linux-dev-env/linux/include/linux/kmod.h \
  /linux-dev-env/linux/include/linux/umh.h \
  /linux-dev-env/linux/include/linux/gfp.h \
    $(wildcard include/config/HIGHMEM) \
    $(wildcard include/config/ZONE_DMA) \
    $(wildcard include/config/ZONE_DMA32) \
    $(wildcard include/config/ZONE_DEVICE) \
    $(wildcard include/config/CONTIG_ALLOC) \
  /linux-dev-env/linux/include/linux/mmzone.h \
    $(wildcard include/config/ARCH_FORCE_MAX_ORDER) \
    $(wildcard include/config/CMA) \
    $(wildcard include/config/MEMORY_ISOLATION) \
    $(wildcard include/config/ZSMALLOC) \
    $(wildcard include/config/UNACCEPTED_MEMORY) \
    $(wildcard include/config/IOMMU_SUPPORT) \
    $(wildcard include/config/SWAP) \
    $(wildcard include/config/HUGETLB_PAGE) \
    $(wildcard include/config/TRANSPARENT_HUGEPAGE) \
    $(wildcard include/config/LRU_GEN_STATS) \
    $(wildcard include/config/LRU_GEN_WALKS_MMU) \
    $(wildcard include/config/MEMORY_FAILURE) \
    $(wildcard include/config/PAGE_EXTENSION) \
    $(wildcard include/config/DEFERRED_STRUCT_PAGE_INIT) \
    $(wildcard include/config/HAVE_MEMORYLESS_NODES) \
    $(wildcard include/config/SPARSEMEM_EXTREME) \
    $(wildcard include/config/HAVE_ARCH_PFN_VALID) \
  /linux-dev-env/linux/include/linux/list_nulls.h \
  /linux-dev-env/linux/include/linux/wait.h \
  /linux-dev-env/linux/include/linux/seqlock.h \
  /linux-dev-env/linux/include/linux/mutex.h \
  /linux-dev-env/linux/include/linux/debug_locks.h \
  /linux-dev-env/linux/include/linux/nodemask.h \
  /linux-dev-env/linux/include/linux/random.h \
    $(wildcard include/config/VMGENID) \
  /linux-dev-env/linux/include/uapi/linux/random.h \
  /linux-dev-env/linux/include/linux/irqnr.h \
  /linux-dev-env/linux/include/uapi/linux/irqnr.h \
  /linux-dev-env/linux/include/linux/pageblock-flags.h \
    $(wildcard include/config/HUGETLB_PAGE_SIZE_VARIABLE) \
  /linux-dev-env/linux/include/linux/page-flags-layout.h \
  /linux-dev-env/linux/include/generated/bounds.h \
  /linux-dev-env/linux/include/linux/mm_types.h \
    $(wildcard include/config/HAVE_ALIGNED_STRUCT_PAGE) \
    $(wildcard include/config/HUGETLB_PMD_PAGE_TABLE_SHARING) \
    $(wildcard include/config/USERFAULTFD) \
    $(wildcard include/config/ANON_VMA_NAME) \
    $(wildcard include/config/PER_VMA_LOCK) \
    $(wildcard include/config/HAVE_ARCH_COMPAT_MMAP_BASES) \
    $(wildcard include/config/MEMBARRIER) \
    $(wildcard include/config/AIO) \
    $(wildcard include/config/MMU_NOTIFIER) \
    $(wildcard include/config/SPLIT_PMD_PTLOCKS) \
    $(wildcard include/config/IOMMU_MM_DATA) \
    $(wildcard include/config/KSM) \
    $(wildcard include/config/CORE_DUMP_DEFAULT_ELF_HEADERS) \
  /linux-dev-env/linux/include/linux/auxvec.h \
  /linux-dev-env/linux/include/uapi/linux/auxvec.h \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/auxvec.h \
  /linux-dev-env/linux/include/linux/kref.h \
  /linux-dev-env/linux/include/linux/refcount.h \
  /linux-dev-env/linux/include/linux/rbtree.h \
  /linux-dev-env/linux/include/linux/rcupdate.h \
    $(wildcard include/config/TINY_RCU) \
    $(wildcard include/config/RCU_STRICT_GRACE_PERIOD) \
    $(wildcard include/config/RCU_LAZY) \
    $(wildcard include/config/TASKS_RCU_GENERIC) \
    $(wildcard include/config/RCU_STALL_COMMON) \
    $(wildcard include/config/KVM_XFER_TO_GUEST_WORK) \
    $(wildcard include/config/RCU_NOCB_CPU) \
    $(wildcard include/config/TASKS_RUDE_RCU) \
    $(wildcard include/config/TREE_RCU) \
    $(wildcard include/config/DEBUG_OBJECTS_RCU_HEAD) \
    $(wildcard include/config/PROVE_RCU) \
    $(wildcard include/config/ARCH_WEAK_RELEASE_ACQUIRE) \
  /linux-dev-env/linux/include/linux/context_tracking_irq.h \
    $(wildcard include/config/CONTEXT_TRACKING_IDLE) \
  /linux-dev-env/linux/include/linux/rcutree.h \
  /linux-dev-env/linux/include/linux/maple_tree.h \
    $(wildcard include/config/MAPLE_RCU_DISABLED) \
    $(wildcard include/config/DEBUG_MAPLE_TREE) \
  /linux-dev-env/linux/include/linux/rwsem.h \
    $(wildcard include/config/RWSEM_SPIN_ON_OWNER) \
    $(wildcard include/config/DEBUG_RWSEMS) \
  /linux-dev-env/linux/include/linux/completion.h \
  /linux-dev-env/linux/include/linux/swait.h \
  /linux-dev-env/linux/include/linux/uprobes.h \
  /linux-dev-env/linux/include/linux/timer.h \
    $(wildcard include/config/DEBUG_OBJECTS_TIMERS) \
  /linux-dev-env/linux/include/linux/ktime.h \
  /linux-dev-env/linux/include/linux/jiffies.h \
  /linux-dev-env/linux/include/vdso/jiffies.h \
  /linux-dev-env/linux/include/generated/timeconst.h \
  /linux-dev-env/linux/include/vdso/ktime.h \
  /linux-dev-env/linux/include/linux/timekeeping.h \
    $(wildcard include/config/GENERIC_CMOS_UPDATE) \
  /linux-dev-env/linux/include/linux/clocksource_ids.h \
  /linux-dev-env/linux/include/linux/debugobjects.h \
    $(wildcard include/config/DEBUG_OBJECTS) \
    $(wildcard include/config/DEBUG_OBJECTS_FREE) \
  /linux-dev-env/linux/arch/x86/include/asm/uprobes.h \
  /linux-dev-env/linux/include/linux/notifier.h \
  /linux-dev-env/linux/include/linux/srcu.h \
    $(wildcard include/config/TINY_SRCU) \
    $(wildcard include/config/NEED_SRCU_NMI_SAFE) \
  /linux-dev-env/linux/include/linux/workqueue.h \
    $(wildcard include/config/DEBUG_OBJECTS_WORK) \
    $(wildcard include/config/FREEZER) \
    $(wildcard include/config/WQ_WATCHDOG) \
  /linux-dev-env/linux/include/linux/workqueue_types.h \
  /linux-dev-env/linux/include/linux/rcu_segcblist.h \
  /linux-dev-env/linux/include/linux/srcutree.h \
  /linux-dev-env/linux/include/linux/rcu_node_tree.h \
    $(wildcard include/config/RCU_FANOUT) \
    $(wildcard include/config/RCU_FANOUT_LEAF) \
  /linux-dev-env/linux/include/linux/percpu_counter.h \
  /linux-dev-env/linux/arch/x86/include/asm/mmu.h \
    $(wildcard include/config/MODIFY_LDT_SYSCALL) \
  /linux-dev-env/linux/include/linux/page-flags.h \
    $(wildcard include/config/PAGE_IDLE_FLAG) \
    $(wildcard include/config/ARCH_USES_PG_ARCH_2) \
    $(wildcard include/config/ARCH_USES_PG_ARCH_3) \
    $(wildcard include/config/HUGETLB_PAGE_OPTIMIZE_VMEMMAP) \
  /linux-dev-env/linux/include/linux/local_lock.h \
  /linux-dev-env/linux/include/linux/local_lock_internal.h \
  /linux-dev-env/linux/include/linux/zswap.h \
    $(wildcard include/config/ZSWAP) \
  /linux-dev-env/linux/include/linux/memory_hotplug.h \
    $(wildcard include/config/ARCH_HAS_ADD_PAGES) \
    $(wildcard include/config/MEMORY_HOTREMOVE) \
  /linux-dev-env/linux/arch/x86/include/generated/asm/mmzone.h \
  /linux-dev-env/linux/include/asm-generic/mmzone.h \
  /linux-dev-env/linux/include/linux/topology.h \
    $(wildcard include/config/USE_PERCPU_NUMA_NODE_ID) \
    $(wildcard include/config/SCHED_SMT) \
  /linux-dev-env/linux/include/linux/arch_topology.h \
    $(wildcard include/config/GENERIC_ARCH_TOPOLOGY) \
  /linux-dev-env/linux/arch/x86/include/asm/topology.h \
    $(wildcard include/config/X86_LOCAL_APIC) \
    $(wildcard include/config/SCHED_MC_PRIO) \
  /linux-dev-env/linux/arch/x86/include/asm/mpspec.h \
    $(wildcard include/config/EISA) \
    $(wildcard include/config/X86_MPPARSE) \
  /linux-dev-env/linux/arch/x86/include/asm/mpspec_def.h \
  /linux-dev-env/linux/arch/x86/include/asm/x86_init.h \
  /linux-dev-env/linux/arch/x86/include/asm/apicdef.h \
  /linux-dev-env/linux/include/asm-generic/topology.h \
  /linux-dev-env/linux/include/linux/cpu_smt.h \
    $(wildcard include/config/HOTPLUG_SMT) \
  /linux-dev-env/linux/include/linux/sysctl.h \
    $(wildcard include/config/SYSCTL) \
  /linux-dev-env/linux/include/uapi/linux/sysctl.h \
  /linux-dev-env/linux/include/linux/elf.h \
    $(wildcard include/config/ARCH_HAVE_EXTRA_ELF_NOTES) \
    $(wildcard include/config/ARCH_USE_GNU_PROPERTY) \
    $(wildcard include/config/ARCH_HAVE_ELF_PROT) \
  /linux-dev-env/linux/arch/x86/include/asm/elf.h \
    $(wildcard include/config/X86_X32_ABI) \
  /linux-dev-env/linux/arch/x86/include/asm/ia32.h \
  /linux-dev-env/linux/include/linux/compat.h \
    $(wildcard include/config/ARCH_HAS_SYSCALL_WRAPPER) \
    $(wildcard include/config/COMPAT_OLD_SIGACTION) \
    $(wildcard include/config/ODD_RT_SIGACTION) \
  /linux-dev-env/linux/include/linux/sem.h \
  /linux-dev-env/linux/include/uapi/linux/sem.h \
  /linux-dev-env/linux/include/linux/ipc.h \
  /linux-dev-env/linux/include/linux/rhashtable-types.h \
  /linux-dev-env/linux/include/uapi/linux/ipc.h \
  /linux-dev-env/linux/arch/x86/include/generated/uapi/asm/ipcbuf.h \
  /linux-dev-env/linux/include/uapi/asm-generic/ipcbuf.h \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/sembuf.h \
  /linux-dev-env/linux/include/linux/socket.h \
  /linux-dev-env/linux/arch/x86/include/generated/uapi/asm/socket.h \
  /linux-dev-env/linux/include/uapi/asm-generic/socket.h \
  /linux-dev-env/linux/arch/x86/include/generated/uapi/asm/sockios.h \
  /linux-dev-env/linux/include/uapi/asm-generic/sockios.h \
  /linux-dev-env/linux/include/uapi/linux/sockios.h \
  /linux-dev-env/linux/include/linux/uio.h \
    $(wildcard include/config/ARCH_HAS_COPY_MC) \
  /linux-dev-env/linux/include/uapi/linux/uio.h \
  /linux-dev-env/linux/include/uapi/linux/socket.h \
  /linux-dev-env/linux/include/uapi/linux/if.h \
  /linux-dev-env/linux/include/uapi/linux/libc-compat.h \
  /linux-dev-env/linux/include/uapi/linux/hdlc/ioctl.h \
  /linux-dev-env/linux/include/linux/fs.h \
    $(wildcard include/config/READ_ONLY_THP_FOR_FS) \
    $(wildcard include/config/FS_POSIX_ACL) \
    $(wildcard include/config/CGROUP_WRITEBACK) \
    $(wildcard include/config/IMA) \
    $(wildcard include/config/FILE_LOCKING) \
    $(wildcard include/config/FSNOTIFY) \
    $(wildcard include/config/FS_ENCRYPTION) \
    $(wildcard include/config/FS_VERITY) \
    $(wildcard include/config/EPOLL) \
    $(wildcard include/config/UNICODE) \
    $(wildcard include/config/QUOTA) \
    $(wildcard include/config/FS_DAX) \
    $(wildcard include/config/BLOCK) \
  /linux-dev-env/linux/include/linux/wait_bit.h \
  /linux-dev-env/linux/include/linux/kdev_t.h \
  /linux-dev-env/linux/include/uapi/linux/kdev_t.h \
  /linux-dev-env/linux/include/linux/dcache.h \
  /linux-dev-env/linux/include/linux/rculist.h \
    $(wildcard include/config/PROVE_RCU_LIST) \
  /linux-dev-env/linux/include/linux/rculist_bl.h \
  /linux-dev-env/linux/include/linux/list_bl.h \
  /linux-dev-env/linux/include/linux/bit_spinlock.h \
  /linux-dev-env/linux/include/linux/lockref.h \
    $(wildcard include/config/ARCH_USE_CMPXCHG_LOCKREF) \
  /linux-dev-env/linux/include/linux/stringhash.h \
    $(wildcard include/config/DCACHE_WORD_ACCESS) \
  /linux-dev-env/linux/include/linux/hash.h \
    $(wildcard include/config/HAVE_ARCH_HASH) \
  /linux-dev-env/linux/include/linux/path.h \
  /linux-dev-env/linux/include/linux/list_lru.h \
  /linux-dev-env/linux/include/linux/shrinker.h \
    $(wildcard include/config/SHRINKER_DEBUG) \
  /linux-dev-env/linux/include/linux/xarray.h \
    $(wildcard include/config/XARRAY_MULTI) \
  /linux-dev-env/linux/include/linux/sched/mm.h \
    $(wildcard include/config/MMU_LAZY_TLB_REFCOUNT) \
    $(wildcard include/config/ARCH_HAS_MEMBARRIER_CALLBACKS) \
  /linux-dev-env/linux/include/linux/sync_core.h \
    $(wildcard include/config/ARCH_HAS_SYNC_CORE_BEFORE_USERMODE) \
    $(wildcard include/config/ARCH_HAS_PREPARE_SYNC_CORE_CMD) \
  /linux-dev-env/linux/arch/x86/include/asm/sync_core.h \
  /linux-dev-env/linux/include/linux/sched/coredump.h \
  /linux-dev-env/linux/include/linux/radix-tree.h \
  /linux-dev-env/linux/include/linux/pid.h \
  /linux-dev-env/linux/include/linux/capability.h \
  /linux-dev-env/linux/include/uapi/linux/capability.h \
  /linux-dev-env/linux/include/linux/semaphore.h \
  /linux-dev-env/linux/include/linux/fcntl.h \
    $(wildcard include/config/ARCH_32BIT_OFF_T) \
  /linux-dev-env/linux/include/uapi/linux/fcntl.h \
  /linux-dev-env/linux/arch/x86/include/generated/uapi/asm/fcntl.h \
  /linux-dev-env/linux/include/uapi/asm-generic/fcntl.h \
  /linux-dev-env/linux/include/uapi/linux/openat2.h \
  /linux-dev-env/linux/include/linux/migrate_mode.h \
  /linux-dev-env/linux/include/linux/percpu-rwsem.h \
  /linux-dev-env/linux/include/linux/rcuwait.h \
  /linux-dev-env/linux/include/linux/sched/signal.h \
    $(wildcard include/config/SCHED_AUTOGROUP) \
    $(wildcard include/config/BSD_PROCESS_ACCT) \
    $(wildcard include/config/TASKSTATS) \
    $(wildcard include/config/STACK_GROWSUP) \
  /linux-dev-env/linux/include/linux/signal.h \
    $(wildcard include/config/DYNAMIC_SIGFRAME) \
  /linux-dev-env/linux/include/linux/sched/jobctl.h \
  /linux-dev-env/linux/include/linux/sched/task.h \
    $(wildcard include/config/HAVE_EXIT_THREAD) \
    $(wildcard include/config/ARCH_WANTS_DYNAMIC_TASK_STRUCT) \
    $(wildcard include/config/HAVE_ARCH_THREAD_STRUCT_WHITELIST) \
  /linux-dev-env/linux/include/linux/uaccess.h \
    $(wildcard include/config/ARCH_HAS_SUBPAGE_FAULTS) \
  /linux-dev-env/linux/include/linux/fault-inject-usercopy.h \
    $(wildcard include/config/FAULT_INJECTION_USERCOPY) \
  /linux-dev-env/linux/include/linux/nospec.h \
  /linux-dev-env/linux/arch/x86/include/asm/uaccess.h \
    $(wildcard include/config/CC_HAS_ASM_GOTO_OUTPUT) \
    $(wildcard include/config/CC_HAS_ASM_GOTO_TIED_OUTPUT) \
    $(wildcard include/config/X86_INTEL_USERCOPY) \
  /linux-dev-env/linux/include/linux/mmap_lock.h \
  /linux-dev-env/linux/arch/x86/include/asm/smap.h \
  /linux-dev-env/linux/arch/x86/include/asm/extable.h \
    $(wildcard include/config/BPF_JIT) \
  /linux-dev-env/linux/arch/x86/include/asm/tlbflush.h \
  /linux-dev-env/linux/include/linux/mmu_notifier.h \
  /linux-dev-env/linux/include/linux/interval_tree.h \
  /linux-dev-env/linux/arch/x86/include/asm/invpcid.h \
  /linux-dev-env/linux/arch/x86/include/asm/pti.h \
  /linux-dev-env/linux/arch/x86/include/asm/pgtable.h \
    $(wildcard include/config/DEBUG_WX) \
    $(wildcard include/config/HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD) \
    $(wildcard include/config/ARCH_HAS_PTE_DEVMAP) \
    $(wildcard include/config/ARCH_SUPPORTS_PMD_PFNMAP) \
    $(wildcard include/config/ARCH_SUPPORTS_PUD_PFNMAP) \
    $(wildcard include/config/HAVE_ARCH_SOFT_DIRTY) \
    $(wildcard include/config/ARCH_ENABLE_THP_MIGRATION) \
    $(wildcard include/config/PAGE_TABLE_CHECK) \
  /linux-dev-env/linux/arch/x86/include/asm/pkru.h \
  /linux-dev-env/linux/arch/x86/include/asm/fpu/api.h \
    $(wildcard include/config/X86_DEBUG_FPU) \
  /linux-dev-env/linux/arch/x86/include/asm/coco.h \
  /linux-dev-env/linux/include/asm-generic/pgtable_uffd.h \
  /linux-dev-env/linux/include/linux/page_table_check.h \
  /linux-dev-env/linux/arch/x86/include/asm/pgtable_64.h \
  /linux-dev-env/linux/arch/x86/include/asm/fixmap.h \
    $(wildcard include/config/PROVIDE_OHCI1394_DMA_INIT) \
    $(wildcard include/config/X86_IO_APIC) \
    $(wildcard include/config/PCI_MMCONFIG) \
    $(wildcard include/config/ACPI_APEI_GHES) \
    $(wildcard include/config/INTEL_TXT) \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/vsyscall.h \
  /linux-dev-env/linux/include/asm-generic/fixmap.h \
  /linux-dev-env/linux/arch/x86/include/asm/pgtable-invert.h \
  /linux-dev-env/linux/arch/x86/include/asm/uaccess_64.h \
  /linux-dev-env/linux/arch/x86/include/asm/runtime-const.h \
  /linux-dev-env/linux/include/asm-generic/access_ok.h \
    $(wildcard include/config/ALTERNATE_USER_ADDRESS_SPACE) \
  /linux-dev-env/linux/include/linux/cred.h \
  /linux-dev-env/linux/include/linux/key.h \
    $(wildcard include/config/KEY_NOTIFICATIONS) \
    $(wildcard include/config/NET) \
  /linux-dev-env/linux/include/linux/assoc_array.h \
    $(wildcard include/config/ASSOCIATIVE_ARRAY) \
  /linux-dev-env/linux/include/linux/sched/user.h \
    $(wildcard include/config/VFIO_PCI_ZDEV_KVM) \
    $(wildcard include/config/IOMMUFD) \
    $(wildcard include/config/WATCH_QUEUE) \
  /linux-dev-env/linux/include/linux/ratelimit.h \
  /linux-dev-env/linux/include/linux/posix-timers.h \
  /linux-dev-env/linux/include/linux/alarmtimer.h \
    $(wildcard include/config/RTC_CLASS) \
  /linux-dev-env/linux/include/linux/hrtimer.h \
    $(wildcard include/config/HIGH_RES_TIMERS) \
    $(wildcard include/config/TIME_LOW_RES) \
    $(wildcard include/config/TIMERFD) \
  /linux-dev-env/linux/include/linux/hrtimer_defs.h \
  /linux-dev-env/linux/include/linux/timerqueue.h \
  /linux-dev-env/linux/include/linux/rcuref.h \
  /linux-dev-env/linux/include/linux/rcu_sync.h \
  /linux-dev-env/linux/include/linux/delayed_call.h \
  /linux-dev-env/linux/include/linux/uuid.h \
  /linux-dev-env/linux/include/linux/errseq.h \
  /linux-dev-env/linux/include/linux/ioprio.h \
  /linux-dev-env/linux/include/linux/sched/rt.h \
  /linux-dev-env/linux/include/linux/iocontext.h \
    $(wildcard include/config/BLK_ICQ) \
  /linux-dev-env/linux/include/uapi/linux/ioprio.h \
  /linux-dev-env/linux/include/linux/fs_types.h \
  /linux-dev-env/linux/include/linux/mount.h \
  /linux-dev-env/linux/include/linux/mnt_idmapping.h \
  /linux-dev-env/linux/include/linux/slab.h \
    $(wildcard include/config/FAILSLAB) \
    $(wildcard include/config/KFENCE) \
    $(wildcard include/config/SLUB_TINY) \
    $(wildcard include/config/SLUB_DEBUG) \
    $(wildcard include/config/SLAB_FREELIST_HARDENED) \
    $(wildcard include/config/SLAB_BUCKETS) \
  /linux-dev-env/linux/include/linux/percpu-refcount.h \
  /linux-dev-env/linux/include/linux/kasan.h \
    $(wildcard include/config/KASAN_STACK) \
    $(wildcard include/config/KASAN_VMALLOC) \
  /linux-dev-env/linux/include/linux/kasan-enabled.h \
  /linux-dev-env/linux/include/linux/kasan-tags.h \
  /linux-dev-env/linux/include/linux/rw_hint.h \
  /linux-dev-env/linux/include/linux/file_ref.h \
  /linux-dev-env/linux/include/linux/unicode.h \
  /linux-dev-env/linux/include/uapi/linux/fs.h \
  /linux-dev-env/linux/include/linux/quota.h \
    $(wildcard include/config/QUOTA_NETLINK_INTERFACE) \
  /linux-dev-env/linux/include/uapi/linux/dqblk_xfs.h \
  /linux-dev-env/linux/include/linux/dqblk_v1.h \
  /linux-dev-env/linux/include/linux/dqblk_v2.h \
  /linux-dev-env/linux/include/linux/dqblk_qtree.h \
  /linux-dev-env/linux/include/linux/projid.h \
  /linux-dev-env/linux/include/uapi/linux/quota.h \
  /linux-dev-env/linux/include/uapi/linux/aio_abi.h \
  /linux-dev-env/linux/include/uapi/linux/unistd.h \
  /linux-dev-env/linux/arch/x86/include/asm/unistd.h \
  /linux-dev-env/linux/arch/x86/include/uapi/asm/unistd.h \
  /linux-dev-env/linux/arch/x86/include/generated/uapi/asm/unistd_64.h \
  /linux-dev-env/linux/arch/x86/include/generated/asm/unistd_64_x32.h \
  /linux-dev-env/linux/arch/x86/include/generated/asm/unistd_32_ia32.h \
  /linux-dev-env/linux/arch/x86/include/asm/compat.h \
  /linux-dev-env/linux/include/linux/sched/task_stack.h \
    $(wildcard include/config/DEBUG_STACK_USAGE) \
  /linux-dev-env/linux/include/uapi/linux/magic.h \
  /linux-dev-env/linux/arch/x86/include/asm/user32.h \
  /linux-dev-env/linux/include/asm-generic/compat.h \
    $(wildcard include/config/COMPAT_FOR_U64_ALIGNMENT) \
  /linux-dev-env/linux/arch/x86/include/asm/syscall_wrapper.h \
  /linux-dev-env/linux/arch/x86/include/asm/user.h \
  /linux-dev-env/linux/arch/x86/include/asm/user_64.h \
  /linux-dev-env/linux/arch/x86/include/asm/fsgsbase.h \
  /linux-dev-env/linux/arch/x86/include/asm/vdso.h \
  /linux-dev-env/linux/include/uapi/linux/elf.h \
  /linux-dev-env/linux/include/uapi/linux/elf-em.h \
  /linux-dev-env/linux/include/linux/kobject.h \
    $(wildcard include/config/UEVENT_HELPER) \
    $(wildcard include/config/DEBUG_KOBJECT_RELEASE) \
  /linux-dev-env/linux/include/linux/sysfs.h \
  /linux-dev-env/linux/include/linux/kernfs.h \
    $(wildcard include/config/KERNFS) \
  /linux-dev-env/linux/include/linux/idr.h \
  /linux-dev-env/linux/include/linux/kobject_ns.h \
  /linux-dev-env/linux/include/linux/moduleparam.h \
    $(wildcard include/config/ALPHA) \
    $(wildcard include/config/PPC64) \
  /linux-dev-env/linux/include/linux/rbtree_latch.h \
  /linux-dev-env/linux/include/linux/error-injection.h \
  /linux-dev-env/linux/include/asm-generic/error-injection.h \
  /linux-dev-env/linux/include/linux/dynamic_debug.h \
  /linux-dev-env/linux/arch/x86/include/asm/module.h \
    $(wildcard include/config/UNWINDER_ORC) \
  /linux-dev-env/linux/include/asm-generic/module.h \
    $(wildcard include/config/HAVE_MOD_ARCH_SPECIFIC) \
    $(wildcard include/config/MODULES_USE_ELF_REL) \
    $(wildcard include/config/MODULES_USE_ELF_RELA) \
  /linux-dev-env/linux/include/linux/bpf.h \
    $(wildcard include/config/FINEIBT) \
    $(wildcard include/config/CGROUP_BPF) \
    $(wildcard include/config/BPF_LSM) \
    $(wildcard include/config/BPF_JIT_ALWAYS_ON) \
    $(wildcard include/config/INET) \
  /linux-dev-env/linux/include/uapi/linux/bpf.h \
    $(wildcard include/config/BPF_LIRC_MODE2) \
    $(wildcard include/config/EFFICIENT_UNALIGNED_ACCESS) \
    $(wildcard include/config/CGROUP_NET_CLASSID) \
    $(wildcard include/config/IP_ROUTE_CLASSID) \
    $(wildcard include/config/BPF_KPROBE_OVERRIDE) \
    $(wildcard include/config/XFRM) \
    $(wildcard include/config/SOCK_CGROUP_DATA) \
    $(wildcard include/config/IPV6) \
  /linux-dev-env/linux/include/uapi/linux/bpf_common.h \
  /linux-dev-env/linux/include/uapi/linux/filter.h \
  /linux-dev-env/linux/include/linux/file.h \
  /linux-dev-env/linux/include/linux/kallsyms.h \
    $(wildcard include/config/KALLSYMS_ALL) \
    $(wildcard include/config/HAVE_FUNCTION_DESCRIPTORS) \
  /linux-dev-env/linux/include/linux/mm.h \
    $(wildcard include/config/HAVE_ARCH_MMAP_RND_BITS) \
    $(wildcard include/config/HAVE_ARCH_MMAP_RND_COMPAT_BITS) \
    $(wildcard include/config/ARCH_USES_HIGH_VMA_FLAGS) \
    $(wildcard include/config/ARCH_HAS_PKEYS) \
    $(wildcard include/config/ARCH_PKEY_BITS) \
    $(wildcard include/config/ARM64_GCS) \
    $(wildcard include/config/X86) \
    $(wildcard include/config/PARISC) \
    $(wildcard include/config/SPARC64) \
    $(wildcard include/config/ARM64_MTE) \
    $(wildcard include/config/HAVE_ARCH_USERFAULTFD_MINOR) \
    $(wildcard include/config/PPC32) \
    $(wildcard include/config/SHMEM) \
    $(wildcard include/config/MIGRATION) \
    $(wildcard include/config/ARCH_HAS_GIGANTIC_PAGE) \
    $(wildcard include/config/ARCH_HAS_PTE_SPECIAL) \
    $(wildcard include/config/SPLIT_PTE_PTLOCKS) \
    $(wildcard include/config/HIGHPTE) \
    $(wildcard include/config/DEBUG_VM_RB) \
    $(wildcard include/config/PAGE_POISONING) \
    $(wildcard include/config/INIT_ON_ALLOC_DEFAULT_ON) \
    $(wildcard include/config/INIT_ON_FREE_DEFAULT_ON) \
    $(wildcard include/config/DEBUG_PAGEALLOC) \
    $(wildcard include/config/ARCH_WANT_OPTIMIZE_DAX_VMEMMAP) \
    $(wildcard include/config/HUGETLBFS) \
    $(wildcard include/config/MAPPING_DIRTY_HELPERS) \
  /linux-dev-env/linux/include/linux/pgalloc_tag.h \
  /linux-dev-env/linux/include/linux/page_ext.h \
  /linux-dev-env/linux/include/linux/stacktrace.h \
    $(wildcard include/config/ARCH_STACKWALK) \
    $(wildcard include/config/STACKTRACE) \
    $(wildcard include/config/HAVE_RELIABLE_STACKTRACE) \
  /linux-dev-env/linux/include/linux/page_ref.h \
    $(wildcard include/config/DEBUG_PAGE_REF) \
  /linux-dev-env/linux/include/linux/sizes.h \
  /linux-dev-env/linux/include/linux/pgtable.h \
    $(wildcard include/config/ARCH_HAS_NONLEAF_PMD_YOUNG) \
    $(wildcard include/config/ARCH_HAS_HW_PTE_YOUNG) \
    $(wildcard include/config/GUP_GET_PXX_LOW_HIGH) \
    $(wildcard include/config/ARCH_WANT_PMD_MKWRITE) \
    $(wildcard include/config/HAVE_ARCH_HUGE_VMAP) \
    $(wildcard include/config/X86_ESPFIX64) \
  /linux-dev-env/linux/include/linux/memremap.h \
    $(wildcard include/config/DEVICE_PRIVATE) \
    $(wildcard include/config/PCI_P2PDMA) \
  /linux-dev-env/linux/include/linux/ioport.h \
  /linux-dev-env/linux/include/linux/cacheinfo.h \
    $(wildcard include/config/ACPI_PPTT) \
    $(wildcard include/config/ARCH_HAS_CPU_CACHE_ALIASING) \
  /linux-dev-env/linux/include/linux/cpuhplock.h \
  /linux-dev-env/linux/include/linux/huge_mm.h \
    $(wildcard include/config/PGTABLE_HAS_HUGE_LEAVES) \
  /linux-dev-env/linux/include/linux/vmstat.h \
    $(wildcard include/config/VM_EVENT_COUNTERS) \
    $(wildcard include/config/DEBUG_TLBFLUSH) \
    $(wildcard include/config/PER_VMA_LOCK_STATS) \
  /linux-dev-env/linux/include/linux/vm_event_item.h \
    $(wildcard include/config/MEMORY_BALLOON) \
    $(wildcard include/config/BALLOON_COMPACTION) \
  /linux-dev-env/linux/arch/x86/include/asm/sections.h \
  /linux-dev-env/linux/include/asm-generic/sections.h \
  /linux-dev-env/linux/include/linux/bpfptr.h \
  /linux-dev-env/linux/include/linux/sockptr.h \
  /linux-dev-env/linux/include/linux/btf.h \
  /linux-dev-env/linux/include/linux/bsearch.h \
  /linux-dev-env/linux/include/linux/btf_ids.h \
  /linux-dev-env/linux/include/uapi/linux/btf.h \
  /linux-dev-env/linux/include/linux/rcupdate_trace.h \
    $(wildcard include/config/TASKS_TRACE_RCU_READ_MB) \
  /linux-dev-env/linux/include/linux/static_call.h \
  /linux-dev-env/linux/include/linux/cpu.h \
    $(wildcard include/config/GENERIC_CPU_DEVICES) \
    $(wildcard include/config/PM_SLEEP_SMP) \
    $(wildcard include/config/PM_SLEEP_SMP_NONZERO_CPU) \
    $(wildcard include/config/ARCH_HAS_CPU_FINALIZE_INIT) \
    $(wildcard include/config/CPU_MITIGATIONS) \
  /linux-dev-env/linux/include/linux/node.h \
    $(wildcard include/config/HMEM_REPORTING) \
  /linux-dev-env/linux/include/linux/device.h \
    $(wildcard include/config/HAS_IOMEM) \
    $(wildcard include/config/GENERIC_MSI_IRQ) \
    $(wildcard include/config/ENERGY_MODEL) \
    $(wildcard include/config/PINCTRL) \
    $(wildcard include/config/ARCH_HAS_DMA_OPS) \
    $(wildcard include/config/DMA_DECLARE_COHERENT) \
    $(wildcard include/config/DMA_CMA) \
    $(wildcard include/config/SWIOTLB) \
    $(wildcard include/config/SWIOTLB_DYNAMIC) \
    $(wildcard include/config/ARCH_HAS_SYNC_DMA_FOR_DEVICE) \
    $(wildcard include/config/ARCH_HAS_SYNC_DMA_FOR_CPU) \
    $(wildcard include/config/ARCH_HAS_SYNC_DMA_FOR_CPU_ALL) \
    $(wildcard include/config/DMA_OPS_BYPASS) \
    $(wildcard include/config/DMA_NEED_SYNC) \
    $(wildcard include/config/IOMMU_DMA) \
    $(wildcard include/config/PM_SLEEP) \
    $(wildcard include/config/OF) \
    $(wildcard include/config/DEVTMPFS) \
  /linux-dev-env/linux/include/linux/dev_printk.h \
  /linux-dev-env/linux/include/linux/energy_model.h \
    $(wildcard include/config/SCHED_DEBUG) \
  /linux-dev-env/linux/include/linux/sched/cpufreq.h \
    $(wildcard include/config/CPU_FREQ) \
  /linux-dev-env/linux/include/linux/sched/topology.h \
    $(wildcard include/config/SCHED_CLUSTER) \
    $(wildcard include/config/SCHED_MC) \
    $(wildcard include/config/CPU_FREQ_GOV_SCHEDUTIL) \
  /linux-dev-env/linux/include/linux/sched/idle.h \
  /linux-dev-env/linux/include/linux/sched/sd_flags.h \
  /linux-dev-env/linux/include/linux/klist.h \
  /linux-dev-env/linux/include/linux/pm.h \
    $(wildcard include/config/VT_CONSOLE_SLEEP) \
    $(wildcard include/config/CXL_SUSPEND) \
    $(wildcard include/config/PM) \
    $(wildcard include/config/PM_CLK) \
    $(wildcard include/config/PM_GENERIC_DOMAINS) \
  /linux-dev-env/linux/include/linux/device/bus.h \
    $(wildcard include/config/ACPI) \
  /linux-dev-env/linux/include/linux/device/class.h \
  /linux-dev-env/linux/include/linux/device/driver.h \
  /linux-dev-env/linux/arch/x86/include/asm/device.h \
  /linux-dev-env/linux/include/linux/pm_wakeup.h \
  /linux-dev-env/linux/include/linux/cpuhotplug.h \
    $(wildcard include/config/HOTPLUG_CORE_SYNC_DEAD) \
  /linux-dev-env/linux/arch/x86/include/asm/static_call.h \
  /linux-dev-env/linux/arch/x86/include/asm/text-patching.h \
    $(wildcard include/config/UML_X86) \
  /linux-dev-env/linux/include/linux/memcontrol.h \
  /linux-dev-env/linux/include/linux/cgroup.h \
    $(wildcard include/config/DEBUG_CGROUP_REF) \
    $(wildcard include/config/CGROUP_CPUACCT) \
    $(wildcard include/config/CGROUP_DATA) \
  /linux-dev-env/linux/include/uapi/linux/cgroupstats.h \
  /linux-dev-env/linux/include/uapi/linux/taskstats.h \
  /linux-dev-env/linux/include/linux/seq_file.h \
  /linux-dev-env/linux/include/linux/string_helpers.h \
  /linux-dev-env/linux/include/linux/ctype.h \
  /linux-dev-env/linux/include/linux/string_choices.h \
  /linux-dev-env/linux/include/linux/ns_common.h \
  /linux-dev-env/linux/include/linux/nsproxy.h \
  /linux-dev-env/linux/include/linux/user_namespace.h \
    $(wildcard include/config/INOTIFY_USER) \
    $(wildcard include/config/FANOTIFY) \
    $(wildcard include/config/BINFMT_MISC) \
    $(wildcard include/config/PERSISTENT_KEYRINGS) \
  /linux-dev-env/linux/include/linux/kernel_stat.h \
    $(wildcard include/config/GENERIC_IRQ_STAT_SNAPSHOT) \
  /linux-dev-env/linux/include/linux/interrupt.h \
    $(wildcard include/config/IRQ_FORCED_THREADING) \
    $(wildcard include/config/GENERIC_IRQ_PROBE) \
    $(wildcard include/config/IRQ_TIMINGS) \
  /linux-dev-env/linux/include/linux/irqreturn.h \
  /linux-dev-env/linux/include/linux/hardirq.h \
  /linux-dev-env/linux/include/linux/context_tracking_state.h \
    $(wildcard include/config/CONTEXT_TRACKING_USER) \
    $(wildcard include/config/CONTEXT_TRACKING) \
  /linux-dev-env/linux/include/linux/ftrace_irq.h \
    $(wildcard include/config/HWLAT_TRACER) \
    $(wildcard include/config/OSNOISE_TRACER) \
  /linux-dev-env/linux/include/linux/vtime.h \
    $(wildcard include/config/VIRT_CPU_ACCOUNTING) \
    $(wildcard include/config/IRQ_TIME_ACCOUNTING) \
  /linux-dev-env/linux/arch/x86/include/asm/hardirq.h \
    $(wildcard include/config/KVM_INTEL) \
    $(wildcard include/config/KVM) \
    $(wildcard include/config/X86_THERMAL_VECTOR) \
    $(wildcard include/config/X86_MCE_THRESHOLD) \
    $(wildcard include/config/X86_MCE_AMD) \
    $(wildcard include/config/X86_HV_CALLBACK_VECTOR) \
    $(wildcard include/config/HYPERV) \
    $(wildcard include/config/X86_POSTED_MSI) \
  /linux-dev-env/linux/arch/x86/include/asm/irq.h \
  /linux-dev-env/linux/arch/x86/include/asm/irq_vectors.h \
    $(wildcard include/config/PCI_MSI) \
  /linux-dev-env/linux/include/linux/cgroup-defs.h \
    $(wildcard include/config/CGROUP_NET_PRIO) \
  /linux-dev-env/linux/include/linux/u64_stats_sync.h \
  /linux-dev-env/linux/arch/x86/include/generated/asm/local64.h \
  /linux-dev-env/linux/include/asm-generic/local64.h \
  /linux-dev-env/linux/arch/x86/include/asm/local.h \
  /linux-dev-env/linux/include/linux/bpf-cgroup-defs.h \
  /linux-dev-env/linux/include/linux/psi_types.h \
  /linux-dev-env/linux/include/linux/kthread.h \
  /linux-dev-env/linux/include/linux/cgroup_subsys.h \
    $(wildcard include/config/CGROUP_DEVICE) \
    $(wildcard include/config/CGROUP_FREEZER) \
    $(wildcard include/config/CGROUP_PERF) \
    $(wildcard include/config/CGROUP_HUGETLB) \
    $(wildcard include/config/CGROUP_PIDS) \
    $(wildcard include/config/CGROUP_RDMA) \
    $(wildcard include/config/CGROUP_MISC) \
    $(wildcard include/config/CGROUP_DEBUG) \
  /linux-dev-env/linux/include/linux/cgroup_refcnt.h \
  /linux-dev-env/linux/include/linux/page_counter.h \
  /linux-dev-env/linux/include/linux/vmpressure.h \
  /linux-dev-env/linux/include/linux/eventfd.h \
  /linux-dev-env/linux/include/uapi/linux/eventfd.h \
  /linux-dev-env/linux/include/linux/writeback.h \
  /linux-dev-env/linux/include/linux/flex_proportions.h \
  /linux-dev-env/linux/include/linux/backing-dev-defs.h \
    $(wildcard include/config/DEBUG_FS) \
  /linux-dev-env/linux/include/linux/blk_types.h \
    $(wildcard include/config/FAIL_MAKE_REQUEST) \
    $(wildcard include/config/BLK_CGROUP_IOCOST) \
    $(wildcard include/config/BLK_INLINE_ENCRYPTION) \
    $(wildcard include/config/BLK_DEV_INTEGRITY) \
  /linux-dev-env/linux/include/linux/bvec.h \
  /linux-dev-env/linux/include/linux/highmem.h \
  /linux-dev-env/linux/include/linux/cacheflush.h \
  /linux-dev-env/linux/arch/x86/include/asm/cacheflush.h \
  /linux-dev-env/linux/include/asm-generic/cacheflush.h \
  /linux-dev-env/linux/include/linux/kmsan.h \
  /linux-dev-env/linux/include/linux/dma-direction.h \
  /linux-dev-env/linux/include/linux/highmem-internal.h \
  /linux-dev-env/linux/include/linux/pagevec.h \
  /linux-dev-env/linux/include/linux/bio.h \
    $(wildcard include/config/BLK_DEV_ZONED) \
  /linux-dev-env/linux/include/linux/mempool.h \
  /linux-dev-env/linux/include/linux/cfi.h \
    $(wildcard include/config/CFI_CLANG) \
  /linux-dev-env/linux/arch/x86/include/asm/cfi.h \
  /linux-dev-env/linux/include/linux/bpf_types.h \
    $(wildcard include/config/NETFILTER_BPF_LINK) \
    $(wildcard include/config/XDP_SOCKETS) \

reg_kfunc.o: $(deps_reg_kfunc.o)

$(deps_reg_kfunc.o):

reg_kfunc.o: $(wildcard /linux-dev-env/linux/tools/objtool/objtool)
