open Def.Presburger;;

let rec ppr_term t =
    "(" ^
    begin match t with
        | T_const n -> string_of_int n
        | T_var v -> "#" ^ string_of_int v
        | T_add (t1, t2) -> ppr_term t1 ^ " + " ^ ppr_term t2
        | T_mulc (n, t) -> string_of_int n ^ " * " ^ ppr_term t
    end ^ ")"
;;

let rec ppr_formula f =
    "(" ^
    begin match f with
        | F_all f -> "forall " ^ ppr_formula f
        | F_exists f -> "exists " ^ ppr_formula f
        | F_neg f -> "~ " ^ ppr_formula f
        | F_and (f1, f2) -> ppr_formula f1 ^ " /\\ " ^ ppr_formula f2
        | F_or (f1, f2) -> ppr_formula f1 ^ " \\/ " ^ ppr_formula f2
        | F_imply (f1, f2) -> ppr_formula f1 ^ " -> " ^ ppr_formula f2
        | F_leq (t1, t2) -> ppr_term t1 ^ " <= " ^ ppr_term t2
        | F_lt (t1, t2) -> ppr_term t1 ^ " < " ^ ppr_term t2
        | F_eq (t1, t2) -> ppr_term t1 ^ " = " ^ ppr_term t2
    end ^ ")"
;;

let formula_of_string str : int * formula =
    Pparser.main Plexer.token (Lexing.from_string str)
;;

let string_of_float f = Format.sprintf "%.03f" f;;

let with_timer f =
    let t = Sys.time () in
    let v = f () in
    (Sys.time () -. t, v)
;;

let median (xs : float list) : float =
  let sorted = List.sort compare xs in
  if List.length sorted mod 2 = 1
      then List.nth sorted (List.length sorted / 2)
      else (List.nth sorted (List.length sorted / 2 - 1) +.
            List.nth sorted (List.length sorted / 2)) /. 2.
;;

let with_timer_median n f =
    let time_list = ref [] in
    for i = 1 to n do
        let (time, _) = with_timer f in
        time_list := time :: !time_list
    done;
    (median !time_list, f ())
;;

let states vars f =
    let ch = finfun_of_finType (exp_finIndexType vars) bool_finType in
    let dfa = dfa_of_nformula vars (normal_f vars f) in
    string_of_int (CardDef.card dfa.dfa_state (fun _ -> true)) ^ ", " ^
(*    string_of_int ((Finite.coq_class dfa.dfa_state).Finite.mixin.Finite.mixin_card) ^ ", " ^ *)
    string_of_int (List.length (enum_reachable ch dfa dfa.dfa_s))
;;

let sat vars f =
    let (time, res) = with_timer_median 5 (fun _ -> presburger_sat vars f) in
    (if res then "SAT" else "UNSAT") ^ " (time: " ^ string_of_float time ^ "s)"
;;

let valid vars f =
    let (time, res) =
        with_timer_median 5 (fun _ -> presburger_valid vars f) in
    (if res then "VALID" else "INVALID") ^
      " (time: " ^ string_of_float time ^ "s)"
;;

let dec vars f =
    let (time, res) = with_timer_median 5 (fun _ -> presburger_st_dec f) in
    (if res then "TRUE" else "FALSE") ^ " (time: " ^ string_of_float time ^ "s)"
;;

exception Invalid_Proc_Name of string;;
exception SIGINT;;

Sys.set_signal Sys.sigint
  (Sys.Signal_handle (fun _ -> print_newline (); raise SIGINT));;

while true do
    try
        print_string ">> ";
        let proc = match read_line () with
            | "STATES" -> states
            | "SAT" -> sat
            | "VALID" -> valid
            | "PP" -> (fun _ -> ppr_formula)
            | name -> raise (Invalid_Proc_Name name)
        in
        print_string ">>> ";
        let (vars, f) = formula_of_string (read_line ()) in
        Gc.full_major(); print_endline ("<< " ^ proc vars f)
    with
        | Invalid_Proc_Name name ->
          print_endline ("<< Invalid procedure name: " ^ name)
        | SIGINT -> print_endline ("<< Interrupted")
        | End_of_file -> print_endline "\n<< Bye!"; exit 0
done
;;