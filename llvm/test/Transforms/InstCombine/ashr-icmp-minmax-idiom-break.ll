; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 2
; RUN: opt < %s -passes=instcombine -S | FileCheck %s

; This test is pre-committed to show sub-optimal codegen due to
; min/max idiom breakage. On AArch64, these constants are also expensive to materialize,
; and therefore generate poor code vs maintaining the min/max idiom.

define i64 @dont_break_minmax_i64(i64 %conv, i64 %conv2) {
; CHECK-LABEL: define i64 @dont_break_minmax_i64
; CHECK-SAME: (i64 [[CONV:%.*]], i64 [[CONV2:%.*]]) {
; CHECK-NEXT:    [[MUL:%.*]] = mul nsw i64 [[CONV]], [[CONV2]]
; CHECK-NEXT:    [[SHR:%.*]] = ashr i64 [[MUL]], 4
; CHECK-NEXT:    [[CMP4_I:%.*]] = icmp slt i64 [[MUL]], 5579712
; CHECK-NEXT:    [[SPEC_SELECT_I:%.*]] = select i1 [[CMP4_I]], i64 [[SHR]], i64 348731
; CHECK-NEXT:    ret i64 [[SPEC_SELECT_I]]
;
  %mul = mul nsw i64 %conv, %conv2
  %shr = ashr i64 %mul, 4
  %cmp4.i = icmp sgt i64 %shr, 348731
  %switch.i = icmp ult i1 %cmp4.i, true
  %spec.select.i = select i1 %switch.i, i64 %shr, i64 348731
  ret i64 %spec.select.i
}
