module FW = Floyd_warshall.Floyd_Warshall;;

Random.self_init ();;

let gen_graph s elems =
  Random.init s;
  Array.init (elems * elems)
    (fun _ -> let n = Random.int 1000 in
              if n < 200
              then Floyd_warshall.Some n
              else Floyd_warshall.None)
;;

let floyd_warshall_ocaml (n : int) g =
  let idx (x : int) (y : int) : int = x * n + y in
  for i = 0 to n - 1 do g.(idx i i) <- Floyd_warshall.Some 0 done;
  for i = 0 to n - 1 do
    for j = 0 to n - 1 do
      for k = 0 to n - 1 do
      let d_jik = FW.add_distance g.(idx j i) g.(idx i k) in
      if FW.lt_distance d_jik g.(idx j k) then g.(idx j k) <- d_jik else ()
      done
    done
  done;
  g
;;

let i_max = 100 in
let j_max = 1 in
let seeds = Array.init (i_max * j_max) (fun _ -> Random.bits ()) in
for i_ = 0 to i_max - 1 do
  let i = (i_ + 1) * 10 in
  for j = 0 to j_max - 1 do
    let benchmark test =
      Utils.with_timer_median 5 (fun _ ->
        test i (gen_graph (seeds.(i_ * j_max + j)) i)) in
    let (time1, res1) = benchmark floyd_warshall_ocaml in
    let (time2, res2) =
      benchmark (fun n -> FW.floyd_warshall
                            (Floyd_warshall.ordinal_finType n)) in
    let (time3, res3) =
      benchmark (fun n -> FW.floyd_warshall_fast
                            (Floyd_warshall.ordinal_finType n)) in
    assert (res1 = res2); assert (res1 = res3);
    print_endline
      ("[" ^ string_of_int i ^ ", " ^ string_of_int j ^ "] "
       ^ "ocaml: "  ^ Utils.string_of_float time1 ^ ", "
       ^ "pure: "   ^ Utils.string_of_float time2 ^ ", "
       ^ "impure: " ^ Utils.string_of_float time3 ^ ", "
       (* ^ "ratio: "  ^ Utils.string_of_float (time2 /. time1) *)
      )
  done
done
;;