;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --generate-stack-ir --roundtrip -all -S -o - | filecheck %s

(module
 ;; CHECK:      (tag $tag (param i32))
 (tag $tag (param i32))
  ;; CHECK:      (func $delegate-child
  ;; CHECK-NEXT:  (try $label$9
  ;; CHECK-NEXT:   (do
  ;; CHECK-NEXT:    (try $label$7
  ;; CHECK-NEXT:     (do
  ;; CHECK-NEXT:      (nop)
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:     (catch $tag
  ;; CHECK-NEXT:      (drop
  ;; CHECK-NEXT:       (pop i32)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:      (try $label$6
  ;; CHECK-NEXT:       (do
  ;; CHECK-NEXT:        (nop)
  ;; CHECK-NEXT:       )
  ;; CHECK-NEXT:       (delegate 2)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (catch $tag
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (pop i32)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $delegate-child
    (try
      (do
        (try
          (do)
          (catch $tag
            (drop
              (pop i32)
            )
            (try
              (do)
              ;; the binary writer must properly handle this delegate which is
              ;; the child of other try's, and not get confused by their
              ;; information on the stack (this is a regression test for us
              ;; properly ending the scope with a delegate and popping the
              ;; relevant stack).
              (delegate 2)
            )
          )
        )
      )
      (catch $tag
        (drop
          (pop i32)
        )
      )
    )
  )
)
