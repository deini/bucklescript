#ifdef TYPE_STRING
type key = string
#elif defined TYPE_INT
type key = int
#else
[%error "unknown type"]
#endif  
type 'a t
(** The type of maps from type [key] to type ['a]. *)

val empty: 'a t
(** The empty map. *)

val ofArray: (key * 'a) array -> 'a t 

val isEmpty: 'a t -> bool
(** Test whether a map is empty or not. *)

val mem:  'a t -> key -> bool

val add: 'a t ->  key -> 'a -> 'a t
(** [add m x y] returns a map containing the same bindings as
   [m], plus a binding of [x] to [y]. If [x] was already bound
   in [m], its previous binding disappears. *)

val singleton: key -> 'a -> 'a t

val remove: 'a t ->  key -> 'a t
(** [remove m x] returns a map containing the same bindings as
   [m], except for [x] which is unbound in the returned map. *)

val merge:
    'a t -> 'b t ->
    (key -> 'a option -> 'b option -> 'c option [@bs]) ->
    'c t
(** [merge m1 m2 f] computes a map whose keys is a subset of keys of [m1]
    and of [m2]. The presence of each such binding, and the corresponding
    value, is determined with the function [f].
 *)

val cmp:  'a t -> 'a t -> ('a -> 'a -> int [@bs]) -> int

val eq: 'a t -> 'a t -> ('a -> 'a -> bool [@bs]) -> bool
(** [equal m1 m2 cmp] tests whether the maps [m1] and [m2] are
   equal, that is, contain equal keys and associate them with
   equal data.  [cmp] is the equality predicate used to compare
   the data associated with the keys. *)

val iter: 'a t -> (key -> 'a -> unit [@bs]) ->  unit
(** [iter m f] applies [f] to all bindings in map [m].
   [f] receives the key as first argument, and the associated value
   as second argument.  The bindings are passed to [f] in increasing
   order with respect to the ordering over the type of the keys. *)

val fold:  'a t -> 'b -> ('b -> key -> 'a -> 'b [@bs]) -> 'b
(** [fold m a f] computes [(f kN dN ... (f k1 d1 a)...)],
   where [k1 ... kN] are the keys of all bindings in [m]
   (in increasing order), and [d1 ... dN] are the associated data. *)

val forAll:  'a t -> (key -> 'a -> bool [@bs]) -> bool
(** [forAll m p] checks if all the bindings of the map
    satisfy the predicate [p].
 *)

val exists:  'a t -> (key -> 'a -> bool [@bs]) -> bool
(** [exists m p] checks if at least one binding of the map
    satisfy the predicate [p].
 *)

val filter: (key -> 'a -> bool [@bs]) -> 'a t -> 'a t
(** [filter m p] returns the map with all the bindings in [m]
    that satisfy predicate [p].
*)

val partition: (key -> 'a -> bool [@bs]) -> 'a t -> 'a t * 'a t
(** [partition p m] returns a pair of maps [(m1, m2)], where
    [m1] contains all the bindings of [s] that satisfy the
    predicate [p], and [m2] is the map with all the bindings of
    [s] that do not satisfy [p].
 *)

val length: 'a t -> int


val toList: 'a t -> (key * 'a) list
(** Return the list of all bindings of the given map.
   The returned list is sorted in increasing order with respect
   to the ordering [Ord.compare], where [Ord] is the argument
   given to {!Map.Make}.
 *)

val minBinding: 'a t -> (key * 'a) option
(** Return the smallest binding of the given map
   or raise
 *)

val maxBinding: 'a t -> (key * 'a) option
(** returns the largest binding of the given map.
 *)



val split: key -> 'a t -> 'a t * 'a option * 'a t
(** [split x m] returns a triple [(l, data, r)], where
      [l] is the map with all the bindings of [m] whose key
    is strictly less than [x];
      [r] is the map with all the bindings of [m] whose key
    is strictly greater than [x];
      [data] is [None] if [m] contains no binding for [x],
      or [Some v] if [m] binds [v] to [x].
 *)

val findOpt: key -> 'a t -> 'a option
(** [findOpt x m] returns the current binding of [x] in [m] *)

val findAssert: key -> 'a t -> 'a
(** raise an exception if not there *)
  
val findWithDefault:  'a t -> key -> 'a  -> 'a

val map: 'a t -> ('a -> 'b [@bs]) ->  'b t
(** [map m f] returns a map with same domain as [m], where the
   associated value [a] of all bindings of [m] has been
   replaced by the result of the application of [f] to [a].
   The bindings are passed to [f] in increasing order
   with respect to the ordering over the type of the keys. *)

val mapi: 'a t -> (key -> 'a -> 'b [@bs]) -> 'b t


val checkInvariant : _ t -> bool 