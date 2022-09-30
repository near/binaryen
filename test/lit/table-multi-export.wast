;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; RUN: wasm-opt %s -all --roundtrip --print | filecheck %s

;; Test that we properly read and write table exports in the binary format.
(module
 ;; Two different tables, each exported.

 ;; CHECK:      (table $0 25 25 funcref)
 (table $0 25 25 funcref)
 ;; CHECK:      (table $1 32 anyref)
 (table $1 32 anyref)

 ;; Each export should export the right table.

 ;; CHECK:      (export "table0" (table $0))
 (export "table0" (table $0))
 ;; CHECK:      (export "table1" (table $1))
 (export "table1" (table $1))
)
