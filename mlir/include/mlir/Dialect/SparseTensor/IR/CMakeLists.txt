add_mlir_dialect(SparseTensorOps sparse_tensor)
add_mlir_doc(SparseTensorOps SparseTensorOps Dialects/ -gen-dialect-doc)

set(LLVM_TARGET_DEFINITIONS SparseTensorAttrDefs.td)
mlir_tablegen(SparseTensorAttrDefs.h.inc -gen-attrdef-decls)
mlir_tablegen(SparseTensorAttrDefs.cpp.inc -gen-attrdef-defs)
mlir_tablegen(SparseTensorAttrEnums.h.inc -gen-enum-decls)
mlir_tablegen(SparseTensorAttrEnums.cpp.inc -gen-enum-defs)
add_public_tablegen_target(MLIRSparseTensorAttrDefsIncGen)

set(LLVM_TARGET_DEFINITIONS SparseTensorTypes.td)
mlir_tablegen(SparseTensorTypes.h.inc -gen-typedef-decls)
mlir_tablegen(SparseTensorTypes.cpp.inc -gen-typedef-defs)
add_public_tablegen_target(MLIRSparseTensorTypesIncGen)
