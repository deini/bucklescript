'use strict';

var Caml_primitive = require("./caml_primitive.js");
var Bs_internalAVLtree = require("./bs_internalAVLtree.js");

function add(t, x, data) {
  if (t !== null) {
    var l = t.left;
    var k = t.key;
    var v = t.value;
    var r = t.right;
    if (x === k) {
      return {
              left: l,
              key: x,
              value: data,
              right: r,
              h: t.h
            };
    } else if (x < k) {
      return Bs_internalAVLtree.bal(add(l, x, data), k, v, r);
    } else {
      return Bs_internalAVLtree.bal(l, k, v, add(r, x, data));
    }
  } else {
    return {
            left: null,
            key: x,
            value: data,
            right: null,
            h: 1
          };
  }
}

function findOpt(x, _n) {
  while(true) {
    var n = _n;
    if (n !== null) {
      var v = n.key;
      if (x === v) {
        return /* Some */[n.value];
      } else {
        _n = x < v ? n.left : n.right;
        continue ;
        
      }
    } else {
      return /* None */0;
    }
  };
}

function findAssert(x, _n) {
  while(true) {
    var n = _n;
    if (n !== null) {
      var v = n.key;
      if (x === v) {
        return n.value;
      } else {
        _n = x < v ? n.left : n.right;
        continue ;
        
      }
    } else {
      throw new Error("Not_found");
    }
  };
}

function findWithDefault(_n, x, def) {
  while(true) {
    var n = _n;
    if (n !== null) {
      var v = n.key;
      if (x === v) {
        return n.value;
      } else {
        _n = x < v ? n.left : n.right;
        continue ;
        
      }
    } else {
      return def;
    }
  };
}

function mem(_n, x) {
  while(true) {
    var n = _n;
    if (n !== null) {
      var v = n.key;
      if (x === v) {
        return /* true */1;
      } else {
        _n = x < v ? n.left : n.right;
        continue ;
        
      }
    } else {
      return /* false */0;
    }
  };
}

function remove(n, x) {
  if (n !== null) {
    var l = n.left;
    var v = n.key;
    var r = n.right;
    if (x === v) {
      if (l !== null) {
        if (r !== null) {
          var kr = [r.key];
          var vr = [r.value];
          var r$1 = Bs_internalAVLtree.removeMinAuxWithRef(r, kr, vr);
          return Bs_internalAVLtree.bal(l, kr[0], vr[0], r$1);
        } else {
          return l;
        }
      } else {
        return r;
      }
    } else if (x < v) {
      return Bs_internalAVLtree.bal(remove(l, x), v, n.value, r);
    } else {
      return Bs_internalAVLtree.bal(l, v, n.value, remove(r, x));
    }
  } else {
    return n;
  }
}

function splitAux(x, n) {
  var l = n.left;
  var v = n.key;
  var d = n.value;
  var r = n.right;
  if (x === v) {
    return /* tuple */[
            l,
            /* Some */[d],
            r
          ];
  } else if (x < v) {
    if (l !== null) {
      var match = splitAux(x, l);
      return /* tuple */[
              match[0],
              match[1],
              Bs_internalAVLtree.join(match[2], v, d, r)
            ];
    } else {
      return /* tuple */[
              null,
              /* None */0,
              n
            ];
    }
  } else if (r !== null) {
    var match$1 = splitAux(x, r);
    return /* tuple */[
            Bs_internalAVLtree.join(l, v, d, match$1[0]),
            match$1[1],
            match$1[2]
          ];
  } else {
    return /* tuple */[
            n,
            /* None */0,
            null
          ];
  }
}

function split(x, n) {
  if (n !== null) {
    return splitAux(x, n);
  } else {
    return /* tuple */[
            null,
            /* None */0,
            null
          ];
  }
}

function merge(s1, s2, f) {
  var exit = 0;
  if (s1 !== null) {
    if (s1.h >= (
        s2 !== null ? s2.h : 0
      )) {
      var l1 = s1.left;
      var v1 = s1.key;
      var d1 = s1.value;
      var r1 = s1.right;
      var match = split(v1, s2);
      return Bs_internalAVLtree.concatOrJoin(merge(l1, match[0], f), v1, f(v1, /* Some */[d1], match[1]), merge(r1, match[2], f));
    } else {
      exit = 1;
    }
  } else if (s2 !== null) {
    exit = 1;
  } else {
    return null;
  }
  if (exit === 1) {
    if (s2 !== null) {
      var l2 = s2.left;
      var v2 = s2.key;
      var d2 = s2.value;
      var r2 = s2.right;
      var match$1 = split(v2, s1);
      return Bs_internalAVLtree.concatOrJoin(merge(match$1[0], l2, f), v2, f(v2, match$1[1], /* Some */[d2]), merge(match$1[2], r2, f));
    } else {
      return /* assert false */0;
    }
  }
  
}

function cmp(s1, s2, cmp$1) {
  var len1 = Bs_internalAVLtree.length0(s1);
  var len2 = Bs_internalAVLtree.length0(s2);
  if (len1 === len2) {
    var _e1 = Bs_internalAVLtree.stackAllLeft(s1, /* [] */0);
    var _e2 = Bs_internalAVLtree.stackAllLeft(s2, /* [] */0);
    var vcmp = cmp$1;
    while(true) {
      var e2 = _e2;
      var e1 = _e1;
      if (e1) {
        if (e2) {
          var h2 = e2[0];
          var h1 = e1[0];
          var c = Caml_primitive.caml_string_compare(h1.key, h2.key);
          if (c) {
            return c;
          } else {
            var cx = vcmp(h1.value, h2.value);
            if (cx) {
              return cx;
            } else {
              _e2 = Bs_internalAVLtree.stackAllLeft(h2.right, e2[1]);
              _e1 = Bs_internalAVLtree.stackAllLeft(h1.right, e1[1]);
              continue ;
              
            }
          }
        } else {
          return 0;
        }
      } else {
        return 0;
      }
    };
  } else if (len1 < len2) {
    return -1;
  } else {
    return 1;
  }
}

function eq(s1, s2, eq$1) {
  var len1 = Bs_internalAVLtree.length0(s1);
  var len2 = Bs_internalAVLtree.length0(s2);
  if (len1 === len2) {
    var _e1 = Bs_internalAVLtree.stackAllLeft(s1, /* [] */0);
    var _e2 = Bs_internalAVLtree.stackAllLeft(s2, /* [] */0);
    var eq$2 = eq$1;
    while(true) {
      var e2 = _e2;
      var e1 = _e1;
      if (e1) {
        if (e2) {
          var h2 = e2[0];
          var h1 = e1[0];
          if (h1.key === h2.key && eq$2(h1.value, h2.value)) {
            _e2 = Bs_internalAVLtree.stackAllLeft(h2.right, e2[1]);
            _e1 = Bs_internalAVLtree.stackAllLeft(h1.right, e1[1]);
            continue ;
            
          } else {
            return /* false */0;
          }
        } else {
          return /* true */1;
        }
      } else {
        return /* true */1;
      }
    };
  } else {
    return /* false */0;
  }
}

function ofArray(xs) {
  var result = null;
  for(var i = 0 ,i_finish = xs.length - 1 | 0; i <= i_finish; ++i){
    var match = xs[i];
    result = add(result, match[0], match[1]);
  }
  return result;
}

var empty = Bs_internalAVLtree.empty0;

var isEmpty = Bs_internalAVLtree.isEmpty0;

var singleton = Bs_internalAVLtree.singleton0;

var iter = Bs_internalAVLtree.iter0;

var fold = Bs_internalAVLtree.fold0;

var forAll = Bs_internalAVLtree.forAll0;

var exists = Bs_internalAVLtree.exists0;

var filter = Bs_internalAVLtree.filter0;

var partition = Bs_internalAVLtree.partition0;

var length = Bs_internalAVLtree.length0;

var toList = Bs_internalAVLtree.toList0;

var minBinding = Bs_internalAVLtree.minKVOpt0;

var maxBinding = Bs_internalAVLtree.maxKVOpt0;

var map = Bs_internalAVLtree.map0;

var mapi = Bs_internalAVLtree.mapi0;

var checkInvariant = Bs_internalAVLtree.checkInvariant;

exports.empty = empty;
exports.ofArray = ofArray;
exports.isEmpty = isEmpty;
exports.mem = mem;
exports.add = add;
exports.singleton = singleton;
exports.remove = remove;
exports.merge = merge;
exports.cmp = cmp;
exports.eq = eq;
exports.iter = iter;
exports.fold = fold;
exports.forAll = forAll;
exports.exists = exists;
exports.filter = filter;
exports.partition = partition;
exports.length = length;
exports.toList = toList;
exports.minBinding = minBinding;
exports.maxBinding = maxBinding;
exports.split = split;
exports.findOpt = findOpt;
exports.findAssert = findAssert;
exports.findWithDefault = findWithDefault;
exports.map = map;
exports.mapi = mapi;
exports.checkInvariant = checkInvariant;
/* No side effect */
