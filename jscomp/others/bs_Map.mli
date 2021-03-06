(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU Library General Public License, with    *)
(*  the special exception on linking described in file ../LICENSE.     *)
(*                                                                     *)
(***********************************************************************)
(** Adapted by authors of BuckleScript without using functors          *)
(** The type of the map keys. *)
type ('k,  'a, 'id) t0 
(** [('k, 'a, id) t] 
    ['k] the key type 
    ['a] the value type
    ['id] is a unique type for each keyed module
*)


type ('k,'v,'id) t = 
  (('k,'id) Bs_Cmp.t,
   ('k,'v, 'id) t0 ) Bs_Bag.bag

(*
    How we remain soundness:
    The only way to create a value of type [_ t] from scratch 
    is through [empty] which requires [_ Bs_Cmp.t]
    The only way to create [_ Bs_Cmp.t] is using [Bs_Cmp.Make] which
    will create a fresh type [id] per module

    Generic operations over tree without [cmp] is still exported 
    (for efficient reaosns) so that [data] does not need be boxed and unboxed.

    The soundness is guarantted in two aspects:
    When create a value of [_ t] it needs both [_ Bs_Cmp.t] and [_ t0].
    [_ Bs_Cmp.t] is an abstract type. Note [add0] requires [_ Bs_Cmp.cmp] which 
    is also an abtract type which can only come from [_ Bs_Cmp.t]

    When destructing a value of [_ t], the ['id] parameter is threaded.

*)

(* should not export [Bs_Cmp.compare]. 
   should only export [Bs_Cmp.t] or [Bs_Cmp.cmp] instead *)




val empty: ('k, 'id) Bs_Cmp.t -> ('k, 'a, 'id) t 

val ofArray:      
  ('k,'id) Bs_Cmp.t -> 
  ('k * 'a) array ->  
  ('k,'a,'id) t 
val isEmpty: ('k, 'a, 'id) t -> bool
val mem: 
   ('k, 'a, 'id) t -> 'k  -> bool
val add: ('k, 'a, 'id) t -> 'k -> 'a ->  ('k, 'a, 'id) t
(** [add m x y ] returns a map containing the same bindings as
    [m], plus a binding of [x] to [y]. If [x] was already bound
    in [m], its previous binding disappears. *)

val singleton: ('k,'id) Bs_Cmp.t ->
  'k -> 'a -> ('k, 'a, 'id) t

val remove:  ('k, 'a, 'id) t -> 'k -> ('k, 'a, 'id) t
(** [remove m x] returns a map containing the same bindings as
    [m], except for [x] which is unbound in the returned map. *)

val merge:
   ('k, 'a, 'id ) t -> ('k, 'b,'id) t -> ('k -> 'a option -> 'b option -> 'c option [@bs]) -> ('k, 'c,'id) t
(** [merge m1 m2 f] computes a map whose keys is a subset of keys of [m1]
    and of [m2]. The presence of each such binding, and the corresponding
    value, is determined with the function [f].
*)    

val cmp: 
    ('k, 'a, 'id) t -> 
    ('k, 'a, 'id) t ->
    ('a -> 'a -> int [@bs]) -> 
     int


val eq:  ('k, 'a, 'id) t -> ('k, 'a, 'id) t -> ('a -> 'a -> bool [@bs]) -> bool
(** [eq m1 m2 cmp] tests whether the maps [m1] and [m2] are
    equal, that is, contain equal keys and associate them with
    equal data.  [cmp] is the equality predicate used to compare
    the data associated with the keys. *)
    
val iter:  ('k, 'a, 'id) t -> ('k -> 'a -> unit [@bs]) -> unit
(** [iter m f] applies [f] to all bindings in map [m].
    [f] receives the 'k as first argument, and the associated value
    as second argument.  The bindings are passed to [f] in increasing
    order with respect to the ordering over the type of the keys. *)
    
val fold: ('k, 'a, 'id) t -> 'b ->  ('b -> 'k -> 'a -> 'b [@bs]) ->  'b
(** [fold m a f] computes [(f kN dN ... (f k1 d1 a)...)],
    where [k1 ... kN] are the keys of all bindings in [m]
    (in increasing order), and [d1 ... dN] are the associated data. *)

val forAll: ('k, 'a, 'id) t -> ('k -> 'a -> bool [@bs]) ->  bool
(** [forAll m p] checks if all the bindings of the map
    satisfy the predicate [p].
*)
    

val exists: ('k, 'a, 'id) t -> ('k -> 'a -> bool [@bs]) ->  bool
(** [exists m p] checks if at least one binding of the map
    satisfy the predicate [p].
*)

val filter: ('k -> 'a -> bool [@bs]) -> ('k, 'a, 'id) t -> ('k, 'a, 'id) t
(** [filter p m] returns the map with all the bindings in [m]
    that satisfy predicate [p].
*)
    
val partition: ('k -> 'a -> bool [@bs]) -> ('k, 'a, 'id) t -> ('k, 'a, 'id) t * ('k, 'a, 'id) t
(** [partition p m] returns a pair of maps [(m1, m2)], where
    [m1] contains all the bindings of [s] that satisfy the
    predicate [p], and [m2] is the map with all the bindings of
    [s] that do not satisfy [p].
*)

val length: ('k, 'a, 'id) t -> int


val toList: ('k, 'a, 'id) t -> ('k * 'a) list
(** Return the list of all bindings of the given map.
    The returned list is sorted in increasing order with respect
    to the ordering [Ord.compare], where [Ord] is the argument
    given to {!Map.Make}.
*)

val minBinding: ('k, 'a, 'id) t -> ('k * 'a) option
(** Return the smallest binding of the given map
    (with respect to the [Ord.compare] ordering), or raise
    [Not_found] if the map is empty.
*)

val maxBinding: ('k, 'a, 'id) t -> ('k * 'a) option
(** Same as {!Map.S.min_binding}, but returns the largest binding
    of the given map.
*)

val split: 'k -> ('k, 'a, 'id) t -> ('k, 'a, 'id) t * 'a option * ('k, 'a, 'id) t
(** [split x m] returns a triple [(l, data, r)], where
      [l] is the map with all the bindings of [m] whose 'k
    is strictly less than [x];
      [r] is the map with all the bindings of [m] whose 'k
    is strictly greater than [x];
      [data] is [None] if [m] contains no binding for [x],
      or [Some v] if [m] binds [v] to [x].
*)

val findOpt:  ('k, 'a, 'id) t -> 'k -> 'a option
(** [find x m] returns the current binding of [x] in [m],
    or raises [Not_found] if no such binding exists. *)
val findAssert: ('k, 'a, 'id) t -> 'k ->  'a

val findWithDefault:
    ('k, 'a, 'id) t -> 'k ->  'a -> 'a 
  
val map: ('k, 'a, 'id) t -> ('a -> 'b [@bs]) ->  ('k ,'b,'id ) t
(** [map m f] returns a map with same domain as [m], where the
    associated value [a] of all bindings of [m] has been
    replaced by the result of the application of [f] to [a].
    The bindings are passed to [f] in increasing order
    with respect to the ordering over the type of the keys. *)

val mapi: ('k, 'a, 'id) t -> ('k -> 'a -> 'b [@bs]) -> ('k, 'b, 'id) t
    

val empty0 : ('k, 'a, 'id) t0
val ofArray0:  
  cmp: ('k,'id) Bs_Cmp.cmp -> 
  ('k * 'a) array ->  
  ('k,'a,'id) t0 
val isEmpty0 : ('k, 'a,'id) t0 -> bool 

val mem0: 
    'k ->     
   ('k, 'a, 'id) t0 -> 
   cmp: ('k,'id) Bs_Cmp.cmp -> 
   bool

val add0: 
    ('k, 'a, 'id) t0 -> 
  'k -> 'a -> 
  cmp: ('k,'id) Bs_Cmp.cmp -> 
  ('k, 'a, 'id) t0 

val singleton0 : 'k -> 'a -> ('k, 'a, 'id) t0    

val remove0:
  ('k, 'a, 'id) t0 ->
  'k -> 
   cmp: ('k,'id) Bs_Cmp.cmp -> 
   ('k, 'a, 'id) t0

val merge0: 
  ('k, 'a, 'id ) t0 -> ('k, 'b,'id) t0 -> 
  ('k -> 'a option -> 'b option -> 'c option [@bs]) -> 
  cmp: ('k,'id) Bs_Cmp.cmp ->     
  ('k, 'c,'id) t0    

val cmp0: 
  ('k, 'a, 'id) t0 -> ('k, 'a, 'id) t0  -> 
  kcmp:('k,'id) Bs_Cmp.cmp -> 
  vcmp:('a -> 'a -> int [@bs]) -> 
  int

val eq0: 
 ('k, 'a, 'id) t0 -> 
 ('k, 'a, 'id) t0 -> 
 kcmp: ('k,'id) Bs_Cmp.cmp ->     
 vcmp:('a -> 'a -> bool [@bs]) ->
 bool


val iter0:  ('k, 'a, 'id) t0 -> ('k -> 'a -> unit [@bs]) -> unit   

val fold0: ('k, 'a, 'id) t0 -> 'b ->  ('b -> 'k -> 'a -> 'b [@bs]) ->  'b

val forAll0: ('k, 'a, 'id) t0 ->  ('k -> 'a -> bool [@bs]) -> bool

val exists0: ('k, 'a, 'id) t0 -> ('k -> 'a -> bool [@bs]) ->  bool

val filter0: ('k -> 'a -> bool [@bs]) -> ('k, 'a, 'id) t0 -> ('k, 'a, 'id) t0

val partition0: ('k -> 'a -> bool [@bs]) -> ('k, 'a, 'id) t0 -> ('k, 'a, 'id) t0 * ('k, 'a, 'id) t0

val length0: ('k, 'a, 'id) t0 -> int

val toList0: ('k, 'a, 'id) t0 -> ('k * 'a) list

val minBinding0: ('k, 'a, 'id) t0 -> ('k * 'a) option


val maxBinding0: ('k, 'a, 'id) t0 -> ('k * 'a) option



val split0: 
  cmp: ('k,'id) Bs_Cmp.cmp ->
  'k -> ('k, 'a, 'id) t0 -> ('k, 'a, 'id) t0 * 'a option * ('k, 'a, 'id) t0



val findOpt0: 
    ('k, 'a, 'id) t0 ->
    'k ->  
    cmp: ('k,'id) Bs_Cmp.cmp -> 
    'a option

val findAssert0: 
    ('k, 'a, 'id) t0 -> 
    'k ->
    cmp: ('k,'id) Bs_Cmp.cmp -> 
   'a 


val findWithDefault0: 
    ('k, 'a, 'id) t0 -> 
    'k -> 
    'a -> 
    cmp: ('k,'id) Bs_Cmp.cmp ->   
    'a 

val map0: ('k, 'a, 'id) t0 -> ('a -> 'b [@bs]) -> ('k ,'b,'id ) t0    

val mapi0: ('k, 'a, 'id) t0 -> ('k -> 'a -> 'b [@bs]) -> ('k, 'b, 'id) t0    

