; RUN: llc -mtriple powerpc-ibm-aix-xcoff -verify-machineinstrs < %s \
; RUN:     -stop-before=ppc-vsx-copy | FileCheck %s --check-prefixes=CHECK32,OPT32
; RUN: llc -mtriple powerpc64-ibm-aix-xcoff -verify-machineinstrs < %s \
; RUN:     -stop-before=ppc-vsx-copy | FileCheck %s --check-prefix CHECK64
; RUN: llc -mtriple powerpc-ibm-aix-xcoff -verify-machineinstrs < %s | FileCheck %s --check-prefixes=TEST32,ASMOPT32
; RUN: llc -mtriple powerpc64-ibm-aix-xcoff -verify-machineinstrs < %s | FileCheck %s --check-prefixes=TEST64,ASMOPT64

; RUN: llc -mtriple powerpc-ibm-aix-xcoff -verify-machineinstrs < %s \
; RUN:     -stop-before=ppc-vsx-copy -O0  | FileCheck %s --check-prefixes=CHECK32,NOOPT32
; RUN: llc -mtriple powerpc64-ibm-aix-xcoff -verify-machineinstrs < %s \
; RUN:     -stop-before=ppc-vsx-copy -O0 | FileCheck %s --check-prefix CHECK64-NOOPT
; RUN: llc -mtriple powerpc-ibm-aix-xcoff -verify-machineinstrs -O0 < %s | FileCheck %s --check-prefixes=TEST32,ASMNOOPT32
; RUN: llc -mtriple powerpc64-ibm-aix-xcoff -verify-machineinstrs -O0 < %s | FileCheck %s --check-prefixes=TEST64,ASMNOOPT64

@i = dso_local global i32 0, align 4 #0
@d = dso_local local_unnamed_addr global double 3.141590e+00, align 8
@f = dso_local local_unnamed_addr global float 0x4005BE76C0000000, align 4 #0
@ll = dso_local local_unnamed_addr global i64 55, align 8
@ilocal = internal global i32 0, align 4

define dso_local void @write_int(i32 signext %in) {
  entry:
    store i32 %in, ptr @i, align 4
    ret void
}
; CHECK32: name:            write_int
; NOOPT32:      %[[SCRATCH:[0-9]+]]:gprc_and_gprc_nor0 = ADDItoc @i, $r2
; NOOPT32-NEXT: STW %{{[0-9]+}}, 0, killed %[[SCRATCH]] :: (store (s32) into @i)
; OPT32:        STW %{{[0-9]+}}, @i, $r2 :: (store (s32) into @i)

; TEST32:         .write_int:
; ASMNOOPT32:       la 4, i[TD](2)
; ASMNOOPT32-NEXT:  stw 3, 0(4)
; ASMOPT32:         stw 3, i[TD](2)

; CHECK64: name:            write_int
; CHECK64:      STW8 %{{[0-9]+}}, @i, $x2  :: (store (s32) into @i)

; CHECK64-NOOPT:  name: write_int
; CHECK64-NOOPT:    %[[SUBREG:[0-9]+]]:gprc = COPY %{{[0-9]}}.sub_32
; CHECK64-NOOPT:    %[[ADDR:[0-9]+]]:g8rc_and_g8rc_nox0 = ADDItoc8 @i, $x2 :: (load (s64) from got)
; CHECK64-NOOPT:    STW %[[SUBREG]], 0, killed %[[ADDR]] :: (store (s32) into @i)

; TEST64:         .write_int:
; ASMNOOPT64:       la 4, i[TD](2)
; ASMNOOPT64-NEXT:  stw 3, 0(4)
; ASMOPT64:         stw 3, i[TD](2)

define dso_local i64 @read_ll() {
  entry:
    %0 = load i64, ptr @ll, align 8
    ret i64 %0
}
; CHECK32: name:            read_ll
; CHECK32: LWZtoc @ll, $r2 :: (load (s32) from got)

; TEST32:       .read_ll:
; TEST32:         lwz 4, L..C0(2)
; TEST32-NEXT:    lwz 3, 0(4)
; TEST32-NEXT:    lwz 4, 4(4)

; CHECK64: name:            read_ll
; CHECK64:   %[[SCRATCH:[0-9]+]]:g8rc_and_g8rc_nox0 = LDtoc @ll, $x2 :: (load (s64) from got)
; CHECK64:   LD 0, killed %[[SCRATCH]]

; CHECK64-NOOPT: name:            read_ll
; CHECK64-NOOPT:   %[[SCRATCH:[0-9]+]]:g8rc_and_g8rc_nox0 = LDtoc @ll, $x2
; CHECK64-NOOPT:   LD 0, %[[SCRATCH]]

; TEST64:       .read_ll:
; TEST64:         ld 3, L..C0(2)
; TEST64-NEXT:    ld 3, 0(3)


define dso_local float @read_float() {
  entry:
    %0 = load float, ptr @f, align 4
    ret float %0
}
; CHECK32: name:            read_float
; NOOPT32: %[[SCRATCH:[0-9]+]]:gprc_and_gprc_nor0 = ADDItoc @f, $r2
; NOOPT32: %{{[0-9]+}}:f4rc = LFS 0, killed %[[SCRATCH]] :: (dereferenceable load (s32) from @f)
; OPT32:   %{{[0-9]+}}:f4rc = LFS @f, $r2 :: (dereferenceable load (s32) from @f)

; TEST32:           .read_float:
; ASMNOOPT32:         la 3, f[TD](2)
; ASMNOOPT32-NEXT:    lfs 1, 0(3)
; ASMOPT32:           lfs 1, f[TD](2)

; CHECK64: name:            read_float
; CHECK64: %{{[0-9]+}}:f4rc = LFS @f, $x2 :: (dereferenceable load (s32) from @f)

; CHECK64-NOOPT: name:            read_float
; CHECK64-NOOPT:   %[[SCRATCH:[0-9]+]]:g8rc_and_g8rc_nox0 = ADDItoc8 @f, $x2
; CHECK64-NOOPT:   %{{[0-9]+}}:f4rc = LFS 0, killed %[[SCRATCH]]

; TEST64:          .read_float:
; ASMNOOPT64:        la 3, f[TD](2)
; ASMNOOPT64-NEXT:   lfs 1, 0(3)
; ASMOPT64:          lfs 1, f[TD](2)

define dso_local void @write_double(double %in) {
  entry:
    store double %in, ptr @d, align 8
    ret void
}
; CHECK32: name:            write_double
; CHECK32: LWZtoc @d, $r2 :: (load (s32) from got)

; TEST32:       .write_double
; TEST32:         lwz 3, L..C1(2)
; TEST32-NEXT:    stfd 1, 0(3)

; CHECK64: name:            write_double
; CHECK64:   %[[SCRATCH:[0-9]+]]:g8rc_and_g8rc_nox0 = LDtoc @d, $x2 :: (load (s64) from got)
; CHECK64:   STFD %{{[0-9]+}}, 0, killed %[[SCRATCH]]

; CHECK64-NOOPT: name:            write_double
; CHECK64-NOOPT:   %[[SCRATCH:[0-9]+]]:g8rc_and_g8rc_nox0 = LDtoc @d, $x2
; CHECK64-NOOPT    STFD %{{[0-9]+}}, 0 %[[SCRATCH]]

; TEST64:       .write_double
; TEST64:         ld 3, L..C1(2)
; TEST64-NEXT:    stfd 1, 0(3)


define dso_local nonnull ptr @addr() {
  entry:
    ret ptr @i
}
; CHECK32: name:            addr
; CHECK32:       %[[SCRATCH:[0-9]+]]:gprc = ADDItoc @i, $r2
; CHECK32-NEXT:  $r3 = COPY %[[SCRATCH]]

; TEST32:       .addr
; TEST32:         la 3, i[TD](2)

; CHECK64: name:            addr
; CHECK64:       %[[SCRATCH:[0-9]+]]:g8rc = ADDItoc8 @i, $x2
; CHECK64-NEXT:  $x3 = COPY %[[SCRATCH]]

; CHECK64-NOOPT: name:            addr
; CHECK64-NOOPT:   %[[SCRATCH:[0-9]+]]:g8rc = ADDItoc8 @i, $x2
; CHECK64-NOOPT:   $x3 = COPY %[[SCRATCH]]

; TEST64:       .addr
; TEST64:         la 3, i[TD](2)

; TEST32:         .toc
; TEST32:           .tc ll[TC],ll[RW]
; TEST32-NOT:       .csect ll[TD]
; TEST32:           .tc d[TC],d[RW]
; TEST32-NOT:       .csect d[TD],2
; TEST32:           .csect i[TD],2
; TEST32-NEXT:      .globl  i[TD]
; TEST32-NEXT:      .align  2
; TEST32-NOT:       .tc i[TC],i[RW]
; TEST32:           .csect f[TD],2
; TEST32-NEXT:      .globl f[TD]
; TEST32-NOT:       .tc f[TD],f[RW]

; TEST64:         .toc
; TEST64:           .tc ll[TC],ll[RW]
; TEST64-NOT:       .csect ll[TD]
; TEST64:           .tc d[TC],d[RW]
; TEST64-NOT:       .csect d[TD],2
; TEST64:           .csect i[TD],2
; TEST64-NEXT:      .globl  i[TD]
; TEST64-NEXT:      .align  2
; TEST64-NOT:       .tc i[TC],i[RW]
; TEST64:           .csect f[TD],2
; TEST64-NEXT:      .globl f[TD]
; TEST64-NOT:       .tc f[TD],f[RW]

attributes #0 = { "toc-data" }
