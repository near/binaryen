;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --local-subtyping -all --enable-gc-nn-locals -S -o - \
;; RUN:   | filecheck %s
;; RUN: wasm-opt %s --local-subtyping -all --enable-gc-nn-locals --nominal -S -o - \
;; RUN:   | filecheck %s --check-prefix=NOMNL

(module
  ;; CHECK:      (type $struct (struct ))
  ;; NOMNL:      (type $struct (struct_subtype  data))
  (type $struct (struct))

  ;; CHECK:      (import "out" "i32" (func $i32 (result i32)))
  ;; NOMNL:      (import "out" "i32" (func $i32 (result i32)))
  (import "out" "i32" (func $i32 (result i32)))

  ;; CHECK:      (func $non-nullable
  ;; CHECK-NEXT:  (local $x (ref $struct))
  ;; CHECK-NEXT:  (local $y (ref $none_=>_i32))
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (ref.as_non_null
  ;; CHECK-NEXT:    (ref.null $struct)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (local.set $y
  ;; CHECK-NEXT:   (ref.func $i32)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  ;; NOMNL:      (func $non-nullable (type $none_=>_none)
  ;; NOMNL-NEXT:  (local $x (ref $struct))
  ;; NOMNL-NEXT:  (local $y (ref $none_=>_i32))
  ;; NOMNL-NEXT:  (local.set $x
  ;; NOMNL-NEXT:   (ref.as_non_null
  ;; NOMNL-NEXT:    (ref.null $struct)
  ;; NOMNL-NEXT:   )
  ;; NOMNL-NEXT:  )
  ;; NOMNL-NEXT:  (local.set $y
  ;; NOMNL-NEXT:   (ref.func $i32)
  ;; NOMNL-NEXT:  )
  ;; NOMNL-NEXT:  (drop
  ;; NOMNL-NEXT:   (local.get $x)
  ;; NOMNL-NEXT:  )
  ;; NOMNL-NEXT: )
  (func $non-nullable
    (local $x (ref null $struct))
    (local $y funcref)
    ;; x is assigned a value that is non-nullable.
    (local.set $x
      (ref.as_non_null (ref.null $struct))
    )
    ;; y is assigned a value that is non-nullable, and also allows a more
    ;; specific heap type.
    (local.set $y
      (ref.func $i32)
    )
    ;; Verify that the presence of a get does not alter things.
    (drop
      (local.get $x)
    )
  )

  ;; CHECK:      (func $uses-default (param $i i32)
  ;; CHECK-NEXT:  (local $x (ref null $struct))
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $i)
  ;; CHECK-NEXT:   (local.set $x
  ;; CHECK-NEXT:    (ref.as_non_null
  ;; CHECK-NEXT:     (ref.null $struct)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  ;; NOMNL:      (func $uses-default (type $i32_=>_none) (param $i i32)
  ;; NOMNL-NEXT:  (local $x (ref null $struct))
  ;; NOMNL-NEXT:  (if
  ;; NOMNL-NEXT:   (local.get $i)
  ;; NOMNL-NEXT:   (local.set $x
  ;; NOMNL-NEXT:    (ref.as_non_null
  ;; NOMNL-NEXT:     (ref.null $struct)
  ;; NOMNL-NEXT:    )
  ;; NOMNL-NEXT:   )
  ;; NOMNL-NEXT:  )
  ;; NOMNL-NEXT:  (drop
  ;; NOMNL-NEXT:   (local.get $x)
  ;; NOMNL-NEXT:  )
  ;; NOMNL-NEXT: )
  (func $uses-default (param $i i32)
    (local $x (ref null any))
    (if
      (local.get $i)
      ;; The only set to this local uses a non-nullable type.
      (local.set $x
        (ref.as_non_null (ref.null $struct))
      )
    )
    (drop
      ;; This get may use the null value, so we can refine the heap type but not
      ;; alter nullability.
      (local.get $x)
    )
  )
)
