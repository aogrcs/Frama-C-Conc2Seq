open Cil_types

let invariant = ref []

let register li  =
  let name = li.l_var_info.lv_name in
  Options.feedback "Registering user invariant: %s" name ;
  let p = match li.l_body with LBpred(p) -> p | _ -> assert false in
  let th = Cil_const.make_logic_var_quant "th" Linteger in
  let loc = Cil.CurrentLoc.get() in
  let visitor = Fun_preds.make_visitor (Logic_const.tvar th) loc in
  
  let new_p = if Thread_local.thlocal_predicate p then
      let p = Visitor.visitFramacPredicate visitor p in
      let valid_th = Atomic_header.valid_thread_id (Logic_const.tvar th) in
      Logic_const.pforall ([th], Logic_const.pimplies (valid_th, p))
    else
      Visitor.visitFramacPredicate visitor p
  in
  invariant := { new_p with pred_name = [ name ] } :: !invariant

let predicates () = !invariant
