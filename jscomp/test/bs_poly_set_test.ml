let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y 
let b loc x =  Mt.bool_suites ~test_id ~suites loc x  

module N = Bs.Set
module I = Array_data_util
module A = Bs.Array
module IntCmp = 
  (val Bs.Cmp.make (fun[@bs] (x:int) y -> compare x y))


let () = 
  let u0 = N.ofArray (module IntCmp) (I.range 0 30) in 
  let u1 = N.remove u0 0 in 
  let u2 = N.remove u1 0 in 
  let u3 = N.remove u2 30 in 
  let u4 = N.remove u3 20 in   
  let r = I.randomRange 0 30 in 
  
  let u5  = N.add u4 3 in 
  let u6 = N.removeArray u5 r in   
  let u7 = N.addArray u6 [|0;1;2;0|] in 
  let u8 = N.removeArray u7 [|0;1;2;3|] in 
  let u9 = N.addArray u8 (I.randomRange 0 20000)  in 
  let u10 = N.addArray u9 (I.randomRange 0 200) in 
  let u11 = N.removeArray u10 (I.randomRange 0 200) in 
  let u12 = N.removeArray u11 (I.randomRange 0 1000) in 
  let u13 = N.removeArray u12 (I.randomRange 0 1000) in 
  let u14 = N.removeArray u13 (I.randomRange 1000 10000) in 
  let u15 = N.removeArray u14 (I.randomRange 10000 (20000 - 1)) in 
  let u16 = N.removeArray u15 (I.randomRange 20000 21000) in
  b __LOC__ (u0 != u1);  
  b __LOC__ (u2 == u1);
  eq __LOC__ (N.length u4) 28; 
  b __LOC__ (Js.eqNull 29 (N.maxNull u4));
  b __LOC__ (Js.eqNull 1 (N.minNull u4));
  b __LOC__ (u4 == u5);  
  b __LOC__ (N.isEmpty u6);  
  eq  __LOC__ (N.length u7) 3 ;
  b __LOC__ (not (N.isEmpty u7));  
  b __LOC__ (N.isEmpty u8);
  b __LOC__ (u9 == u10);
  b __LOC__ (N.mem u10 20);
  b __LOC__ (N.mem u10 21);
  eq __LOC__ (N.length u10) 20001;
  eq __LOC__ (N.length u11) 19800;  
  eq __LOC__ (N.length u12) 19000;
  b __LOC__ (u12 == u13);  
  eq __LOC__ (N.length u14) 10000;
  eq __LOC__ (N.length u15) 1 ;
  b __LOC__ (N.mem u15 20000);
  b __LOC__ (not @@ N.mem u15 2000);
  b __LOC__ (N.isEmpty u16);
  let u17  = N.ofArray (module IntCmp) (I.randomRange 0 100) in 
  let u18 = N.ofArray (module IntCmp) (I.randomRange 59 200) in 
  let u19 = N.union u17 u18 in 
  let u20 = N.ofArray (module IntCmp) (I.randomRange 0 200) in 
  b __LOC__ (N.eq u19 u20);
  let u21 =  N.inter u17 u18 in 
  eq __LOC__ (N.toArray u21) (I.range 59 100);
  let u22 = N.diff u17 u18 in 
  eq __LOC__ (N.toArray u22) (I.range 0 58);
  let u23 = N.diff u18 u17 in 
  let u24 = N.union u18 u17 in 
  b __LOC__ (N.eq u24 u19);
  eq __LOC__ (N.toArray u23) (I.range 101 200);
  b __LOC__ (N.subset u23 u18);
  b __LOC__ (not (N.subset u18 u23));
  b __LOC__ (N.subset u22 u17);
  b __LOC__ (N.subset u21 u17 && N.subset u21 u18);
  b __LOC__ (Js.eqNull 47 (N.findNull u22 47));
  b __LOC__ ( Some 47 = (N.findOpt u22 47));
  b __LOC__ (Js.Null.test (N.findNull u22 59));
  b __LOC__ (None = (N.findOpt u22 59));
  let u25 = N.add u22 59 in 
  eq __LOC__ (N.length u25) 60
  
;; Mt.from_pair_suites __FILE__ !suites  