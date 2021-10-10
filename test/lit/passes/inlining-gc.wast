;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --inlining --enable-gc-nn-locals -all -S -o - | filecheck %s

(module
 ;; CHECK:      (type $struct (struct (field i32)))
 (type $struct (struct (field i32)))

 ;; CHECK:      (global $global (mut (ref null $struct)) (ref.null $struct))
 (global $global (mut (ref null $struct)) (ref.null $struct))

 ;; CHECK:      (global $other (mut (ref null $struct)) (ref.null $struct))
 (global $other (mut (ref null $struct)) (ref.null $struct))

 ;; CHECK:      (func $caller-nullable
 ;; CHECK-NEXT:  (local $0 funcref)
 ;; CHECK-NEXT:  (block $__inlined_func$target-nullable
 ;; CHECK-NEXT:   (local.set $0
 ;; CHECK-NEXT:    (ref.null func)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (nop)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $caller-nullable
  ;; Call a function with a nullable local. After the inlining there will
  ;; be a new local in this function for the use of the inlined code, and also
  ;; we assign the null value to that local in the inlined block (which does
  ;; not matter much here, but in general if we had a loop that the inlined
  ;; block was inside of, that would be important to get the right behavior).
  (call $target-nullable)
 )

 (func $target-nullable
  (local $1 (ref null func))
 )

 ;; CHECK:      (func $caller-non-nullable
 ;; CHECK-NEXT:  (local $0 (ref func))
 ;; CHECK-NEXT:  (block $__inlined_func$target-non-nullable
 ;; CHECK-NEXT:   (nop)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $caller-non-nullable
  ;; Call a function with a non-nullable local. After the inlining there will
  ;; be a new local in this function for the use of the inlined code. We do not
  ;; need to zero it out (such locals cannot be used before being set anyhow, so
  ;; no zero is needed; and we cannot set a zero anyhow as none exists for the
  ;; type).
  (call $target-non-nullable)
 )

 (func $target-non-nullable
  (local $1 (ref func))
 )

 ;; CHECK:      (func $unlikely-call
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (ref.is_null
 ;; CHECK-NEXT:    (global.get $global)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (global.set $global
 ;; CHECK-NEXT:    (struct.new $struct
 ;; CHECK-NEXT:     (call $helper)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $unlikely-call
  ;; This "once" pattern is unlikely to have its condition be true more than
  ;; once, so we should not inline into its body.
  (if
   (ref.is_null
    (global.get $global)
   )
   (global.set $global
    (struct.new $struct
     (call $helper)
    )
   )
  )
 )

 ;; CHECK:      (func $unlikely-call-bad-condition
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (ref.is_data
 ;; CHECK-NEXT:    (global.get $global)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (global.set $global
 ;; CHECK-NEXT:    (struct.new $struct
 ;; CHECK-NEXT:     (block (result i32)
 ;; CHECK-NEXT:      (block $__inlined_func$helper (result i32)
 ;; CHECK-NEXT:       (i32.const 42)
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $unlikely-call-bad-condition
  ;; The condition should be "is null". Here it isn't, so we will inline.
  (if
   (ref.is_data
    (global.get $global)
   )
   (global.set $global
    (struct.new $struct
     (call $helper)
    )
   )
  )
 )

 ;; CHECK:      (func $unlikely-call-bad-global
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (ref.is_null
 ;; CHECK-NEXT:    (global.get $global)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (global.set $other
 ;; CHECK-NEXT:    (struct.new $struct
 ;; CHECK-NEXT:     (block (result i32)
 ;; CHECK-NEXT:      (block $__inlined_func$helper (result i32)
 ;; CHECK-NEXT:       (i32.const 42)
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $unlikely-call-bad-global
  ;; A different global is written than is checked, so so it does not fit the
  ;; "once" pattern and we will inline.
  (if
   (ref.is_null
    (global.get $global)
   )
   (global.set $other
    (struct.new $struct
     (call $helper)
    )
   )
  )
 )

 ;; CHECK:      (func $unlikely-call-else
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (ref.is_null
 ;; CHECK-NEXT:    (global.get $global)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (global.set $global
 ;; CHECK-NEXT:    (struct.new $struct
 ;; CHECK-NEXT:     (block (result i32)
 ;; CHECK-NEXT:      (block $__inlined_func$helper (result i32)
 ;; CHECK-NEXT:       (i32.const 42)
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (nop)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $unlikely-call-else
  ;; This if has an else, so it does not fit the "once" pattern and we will
  ;; inline.
  (if
   (ref.is_null
    (global.get $global)
   )
   (global.set $global
    (struct.new $struct
     (call $helper)
    )
   )
   (nop)
  )
 )

 ;; CHECK:      (func $helper (result i32)
 ;; CHECK-NEXT:  (i32.const 42)
 ;; CHECK-NEXT: )
 (func $helper (result i32)
  (i32.const 42)
 )
)
