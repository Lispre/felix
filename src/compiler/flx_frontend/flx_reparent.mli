(** Reparenting *)

open Flx_ast
open Flx_types
open Flx_set
open Flx_mtypes2
open Flx_call

val reparent_children :
  sym_state_t ->
  usage_table_t ->
  Flx_bsym_table.t ->
  bid_t ->                          (* routine index *)
  bid_t option ->                   (* parent *)
  (string, string) Hashtbl.t ->     (* relabel *)
  bool ->                           (* rescan flag *)
  bid_t list ->                     (* any extra symbols to remap *)
  (bid_t, bid_t) Hashtbl.t          (* returns revariable map *)

val specialise_symbol:
  sym_state_t ->
  usage_table_t ->
  Flx_bsym_table.t ->
  bid_t ->                          (* routine index *)
  bid_t option ->                   (* parent *)
  (string, string) Hashtbl.t ->     (* relabel *)
  bool ->                           (* rescan flag *)
  bid_t * Flx_btype.t list          (* result instance *)

val remap_expr :
  sym_state_t ->
  Flx_bsym_table.t ->
  (string, string) Hashtbl.t ->     (* relabel *)
  (bid_t, bid_t) Hashtbl.t ->       (* revariable *)
  Flx_bexpr.t ->
  Flx_bexpr.t


