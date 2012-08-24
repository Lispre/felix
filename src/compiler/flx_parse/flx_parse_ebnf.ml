open Flx_token

(* Translate all identifiers into nonterminals *)
let fixup_prio sr rhs =
  let rec aux inp out = match inp with
  | [] -> List.rev out

  (* Default relation is greater equal *)
  | NAME s :: LSQB _ :: NAME p :: RSQB _ :: t ->
    aux t (NONTERMINAL (s,Priority_Greatereq p)::out)

  | NAME s :: LSQB _ :: LESS _ :: NAME p :: RSQB _ :: t ->
    aux t (NONTERMINAL (s,Priority_Less p)::out)
  | NAME s :: LSQB _ :: LESSEQUAL _ :: NAME p :: RSQB _ :: t ->
    aux t (NONTERMINAL (s,Priority_Lesseq p)::out)
  | NAME s :: LSQB _ :: GREATER _ :: NAME p :: RSQB _ :: t ->
    aux t (NONTERMINAL (s,Priority_Greater p)::out)
  | NAME s :: LSQB _ :: GREATEREQUAL _ :: NAME p :: RSQB _ :: t ->
    aux t (NONTERMINAL (s,Priority_Greatereq  p)::out)
  | NAME s :: LSQB _ :: EQUAL _ :: NAME p :: RSQB _ :: t ->
    aux t (NONTERMINAL (s,Priority_Eq p)::out)
   
  | NAME s :: LSQB :: _ ->
    failwith "Dangling [ in grammar"
 
  | NAME s ::t ->
    aux t (NONTERMINAL (s,Priority_None)::out)
  | h :: t -> aux t (h::out)
  in aux rhs []


(* create rules for nt* nt+ and nt? Use after fixup_prio removes identifiers *)
let fixup_suffix_scheme sr pcounter rhs =
  let rec aux inp out extras = match inp with
  | [] -> List.rev out,extras
  | NONTERMINAL (s,p) :: STAR :: t ->
    let x = string_of_int (!pcounter) in incr pcounter;
    let slr = s ^ "__rlist_"^x in
    let sl = s ^ "__list_"^x in
    let rule0 = slr,Priority_Default,[NONTERMINAL(sl,Priority_None)],"(reverse _1)","",sr in
    let rule1 = sl,Priority_Default,[NONTERMINAL(sl,Priority_None);NONTERMINAL(s,p)],"(cons _2 _1)","",sr in
    let rule2 = sl,Priority_Default,[],"'()","",sr in
    aux t (NONTERMINAL (slr,Priority_None)::out) (rule0::rule1::rule2::extras)

  | NONTERMINAL (s,p) :: PLUS :: t ->
    let x = string_of_int (!pcounter) in incr pcounter;
    let slr = s ^ "__nerlist_"^x in
    let sl = s ^ "__nelist_"^x in
    let rule0 = slr,Priority_Default,[NONTERMINAL(sl,Priority_None)],"(reverse _1)","",sr in
    let rule1 = sl,Priority_Default,[NONTERMINAL(sl,Priority_None);NONTERMINAL(s,p)],"(cons _2 _1)","",sr in
    let rule2 = sl,Priority_Default,[NONTERMINAL(s,Priority_None)],"`(,_1)","",sr in
    aux t (NONTERMINAL (slr,Priority_None)::out) (rule0::rule1::rule2::extras)

  | NONTERMINAL (s,p) :: QUEST :: t ->
    let x = string_of_int (!pcounter) in incr pcounter;
    let sl = s ^ "__opt_"^x in
    let rule1 = sl,Priority_Default,[NONTERMINAL(s,p)],"`(,_1)","",sr in
    let rule2 = sl,Priority_Default,[],"()","",sr in
    aux t (NONTERMINAL (sl,Priority_None)::out) (rule1::rule2::extras)

  | other :: QUEST :: t ->
    let x = string_of_int (!pcounter) in incr pcounter;
    let sl = "__opt_"^x in
    let rule1 = sl,Priority_Default,[other],"()","",sr in
    let rule2 = sl,Priority_Default,[],"()","",sr in
    aux t (NONTERMINAL (sl,Priority_None)::out) (rule1::rule2::extras)

  | h :: t -> aux t (h::out) extras
  in aux rhs [] []

(* Translation for string parser nt* nt+ and  nt? *)
let fixup_suffix_string sr pcounter rhs =
  let rec aux inp out extras = match inp with
  | [] -> List.rev out,extras
  | NONTERMINAL (s,p) :: STAR :: t ->
    let x = string_of_int (!pcounter) in incr pcounter;
    let slr = s ^ "__rlist_"^x in
    let sl = s ^ "__list_"^x in
    let rule0 = slr,Priority_Default,[NONTERMINAL(sl,Priority_None)],"_1","",sr in
    let rule1 = sl,Priority_Default,[NONTERMINAL(sl,Priority_None);NONTERMINAL(s,p)],"(strcat `(,_1 ,_2))","",sr in
    let rule2 = sl,Priority_Default,[],"\"\"","",sr in
    aux t (NONTERMINAL (slr,Priority_None)::out) (rule0::rule1::rule2::extras)

  | NONTERMINAL (s,p) :: PLUS :: t ->
    let x = string_of_int (!pcounter) in incr pcounter;
    let slr = s ^ "__nerlist_"^x in
    let sl = s ^ "__nelist_"^x in
    let rule0 = slr,Priority_Default,[NONTERMINAL(sl,Priority_None)],"_1","",sr in
    let rule1 = sl,Priority_Default,[NONTERMINAL(sl,Priority_None);NONTERMINAL(s,p)],"(strcat `(,_1 ,_2))","",sr in
    let rule2 = sl,Priority_Default,[NONTERMINAL(s,Priority_None)],"_1","",sr in
    aux t (NONTERMINAL (slr,Priority_None)::out) (rule0::rule1::rule2::extras)

  | NONTERMINAL (s,p) :: QUEST :: t ->
    let x = string_of_int (!pcounter) in incr pcounter;
    let sl = s ^ "__opt_"^x in
    let rule1 = sl,Priority_Default,[NONTERMINAL(s,p)],"_1","",sr in
    let rule2 = sl,Priority_Default,[],"\"\"","",sr in
    aux t (NONTERMINAL (sl,Priority_None)::out) (rule1::rule2::extras)

  | other :: QUEST :: t ->
    let x = string_of_int (!pcounter) in incr pcounter;
    let sl = "__opt_"^x in
    let rule1 = sl,Priority_Default,[other],"_1","",sr in
    let rule2 = sl,Priority_Default,[],"\"\"","",sr in
    aux t (NONTERMINAL (sl,Priority_None)::out) (rule1::rule2::extras)

  | h :: t -> aux t (h::out) extras
  in aux rhs [] []

let fixup_suffix sr pcounter kind rhs =
  match kind with
  | `Sval -> fixup_suffix_scheme sr pcounter rhs
  | `String -> fixup_suffix_string sr pcounter rhs

