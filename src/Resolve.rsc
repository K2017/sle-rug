module Resolve

import AST;

/*
 * Name resolution for QL
 */ 


// modeling declaring occurrences of names
alias Def = rel[str name, loc def];

// modeling use occurrences of names
alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[
  Use uses, 
  Def defs, 
  UseDef useDef
]; 

RefGraph resolve(AForm f) = <us, ds, us o ds>
  when Use us := uses(f), Def ds := defs(f);

Use uses(AForm f) {
  Use ret = {};
  visit(f) {
    case /ref(str x, src = loc u): ret = ret + <u, x>;
  };
  return ret; 
}

Def defs(AForm f) {
  Def ret = {};
  visit(f) {
    case /question(_,AId id,_): ret = ret + <id.name, id.src>;
    case /computed(_,AId id,_,_): ret = ret + <id.name, id.src>;
  };
  return ret; 
}
