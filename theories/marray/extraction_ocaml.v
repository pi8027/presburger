Require Import all_ssreflect all_algebra ordinal_ext core.
Require Extraction.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Load "../extraction_common_dffun.v".

(* nat *)

Extract Inlined Constant predn' => "(* predn' *)pred".

Extract Inlined Constant subn' => "(* subn' *)(-)".

(* ordinal *)

Extraction Inline
  idx_of_iter idx_of_pred_iter ord_leq ord_pred ord_pred'.

(* copyTypes *)

Extraction Implicit ffun_copy [I].
Extract Inlined Constant ffun_copy => "Array.copy".

Extraction Inline
  CopyableMixin.copy CopyableMixin.ffun_mixin CopyableMixin.prod_mixin
  Copyable.class Copyable.pack Copyable.clone
  copy Copyable.finfun_copyType Copyable.prod_copyType.

(* array state monad *)

Extraction Implicit astate_GET_ [I].
Extraction Implicit astate_SET_ [I].
Extraction Implicit astate_GET [I].
Extraction Implicit astate_SET [I].

Extract Inductive AState => "(->)"
  [(* return *) "(fun a s -> a)"
   (* bind *)   "(fun (f, g) s -> let r = f s in g r s)"
   (* frameL *) "(fun f (sl, _) -> f sl)"
   (* frameR *) "(fun f (_, sr) -> f sr)"
   (* GET *)    "(fun i s -> s.(i))"
   (* SET *)    "(fun (i, x) s -> s.(i) <- x)"]
  "(* It is not permitted to use AState_rect in extracted code. *)".
Extract Type Arity AState 1.

Extract Inlined Constant astate_ret =>
  "(* return *) (fun a s -> a)".
Extract Inlined Constant astate_bind =>
  "(* bind *) (fun f g s -> let r = f s in g r s)".
Extract Inlined Constant astate_frameL =>
  "(* frameL *) (fun f (sl, _) -> f sl)".
Extract Inlined Constant astate_frameR =>
  "(* frameR *) (fun f (_, sr) -> f sr)".
Extract Inlined Constant astate_GET =>
  "(* GET *) (fun i s -> s.(i))".
Extract Inlined Constant astate_SET =>
  "(* SET *) (fun i x s -> s.(i) <- x)".
Extract Inlined Constant run_AState_raw =>
  "(* run_AState_raw *) (fun a s -> (a s, s))".

Extraction Inline
  run_AState
  SWAP swap
  iterate_revord iterate_fin iterate_revfin
  miterate_revord miterate_ord miterate_revord'
  miterate_revboth miterate_both
  miterate_revfin miterate_fin miterate_revfin'.
