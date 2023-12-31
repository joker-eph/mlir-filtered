// RUN: mlir-opt %s -convert-arm-sme-to-scf -cse -split-input-file | FileCheck %s

// CHECK-LABEL: func.func @arm_sme_tile_load(
// CHECK-SAME:                               %[[SRC:.*]]: memref<?x?xi32>) {
// CHECK-NEXT:    %[[TILE_ID:.*]] = arm_sme.get_tile_id : i32
// CHECK-NEXT:    %[[CAST_TILE_TO_VECTOR:.*]] = arm_sme.cast_tile_to_vector %[[TILE_ID]] : i32 to vector<[4]x[4]xi32>
// CHECK-DAG:     %[[C0:.*]] = arith.constant 0 : index
// CHECK-DAG:     %[[C1:.*]] = arith.constant 1 : index
// CHECK-DAG:     %[[C4:.*]] = arith.constant 4 : index
// CHECK-DAG:     %[[VSCALE:.*]] = vector.vscale
// CHECK-NEXT:    %[[NUM_TILE_SLICES:.*]] = arith.muli %[[C4]], %[[VSCALE]] : index
// CHECK-NEXT:    scf.for %[[TILE_SLICE_INDEX:.*]] = %[[C0]] to %[[NUM_TILE_SLICES]] step %[[C1]] {
// CHECK-NEXT:      arm_sme.load_tile_slice %[[SRC]]{{\[}}%[[TILE_SLICE_INDEX]]], %[[CAST_TILE_TO_VECTOR]], %[[TILE_SLICE_INDEX]] : memref<?x?xi32>, vector<[4]x[4]xi32>
func.func @arm_sme_tile_load(%src : memref<?x?xi32>) {
  %c0 = arith.constant 0 : index
  %tile = arm_sme.tile_load %src[%c0, %c0] : memref<?x?xi32>, vector<[4]x[4]xi32>
  return
}

// -----

// CHECK-LABEL: func.func @arm_sme_tile_store(
// CHECK-SAME:                                %[[TILE:.*]]: vector<[4]x[4]xi32>,
// CHECK-SAME:                                %[[DEST:.*]]: memref<?x?xi32>) {
// CHECK-DAG:     %[[C0:.*]] = arith.constant 0 : index
// CHECK-DAG:     %[[C1:.*]] = arith.constant 1 : index
// CHECK-DAG:     %[[C4:.*]] = arith.constant 4 : index
// CHECK-DAG:     %[[VSCALE:.*]] = vector.vscale
// CHECK:         %[[NUM_TILE_SLICES:.*]] = arith.muli %[[C4]], %[[VSCALE]] : index
// CHECK:         scf.for %[[TILE_SLICE_INDEX:.*]] = %[[C0]] to %[[NUM_TILE_SLICES]] step %[[C1]] {
// CHECK:           arm_sme.store_tile_slice %[[TILE]], %[[TILE_SLICE_INDEX]], %[[DEST]]{{\[}}%[[TILE_SLICE_INDEX]]] : memref<?x?xi32>, vector<[4]x[4]xi32>
func.func @arm_sme_tile_store(%tile : vector<[4]x[4]xi32>, %dest : memref<?x?xi32>) {
  %c0 = arith.constant 0 : index
  arm_sme.tile_store %tile, %dest[%c0, %c0] : memref<?x?xi32>, vector<[4]x[4]xi32>
  return
}
