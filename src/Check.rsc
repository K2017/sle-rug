module Check

import AST;
import Resolve;
import Message; // see standard library
import IO;
import Location;

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
  TEnv env = {};
  visit(f) {
    case /question(str label, AId id, AType tp, ex = AExpr exp, src = loc u): env = env + <id.src, id.name, label, toType(tp)>;
  }
  return env; 
}

Type toType(AType t) {
    switch(t) {
        case integer(): return tint();
        case string(): return tstr();
        case boolean(): return tbool();
        default: return tunknown();
    }
}

Type toType(AConst c) {
    switch(c) {
        case integer(_): return tint();
        case string(_): return tstr();
        case boolean(_): return tbool();
        default: return tunknown();
    }
}

AType fromType(Type t) {
    switch(t) {
        case tint(): return integer();
        case tstr(): return string();
        case tbool(): return boolean();
        default: return unknown();
    }
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  for(/AQuestion q := f) {
    msgs += check(q, tenv, useDef);
  }
  return msgs;
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  switch(q) {
    case question(str label, AId id, AType tp, ex = AExpr exp, src = loc u): {
      str qname = "<id.name>";
      Type qtype = toType(tp);
      if (exp != empty()) {
        msgs += check(exp, tenv, useDef);
        if (qtype != typeOf(exp, tenv, useDef)) {
          msgs += {error("Expression does not match declared type", u)};
        }
      }
      for(<loc def, str name, str l, Type t> <- tenv) {
        if(name == qname && t != qtype && isBefore(def, u)) {
          msgs += {error("Declaration type mismatch", u)};
        }
        if(l == label && isBefore(def, u)) {
          msgs += {warning("Duplicate label", u)};
        }
      } 
    }
  }
  return msgs; 
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  Type expType = typeOf(e, tenv, useDef);
  AType expAtype = fromType(expType);
  str msg = "Expected type <expAtype>"[..-2];

  switch (e) {
    case ref(id, src = loc u):
      msgs += { error("Undeclared question", u) | useDef[u] == {} };
    case not(exp, src = loc u): {
      msgs += { error(msg, u) 
              | expType != typeOf(exp) 
              };
    }
    case mul(lhs,rhs,src = loc u): {
      msgs += { error(msg, u)
              | expType != typeOf(lhs, tenv, useDef) || expType != typeOf(rhs, tenv, useDef)
              || typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)
              };
    }
    case div(lhs,rhs,src = loc u): {
      msgs += { error(msg, u)
              | expType != typeOf(lhs, tenv, useDef) || expType != typeOf(rhs, tenv, useDef) 
              || typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)
              };
    }
    case add(lhs,rhs,src = loc u): {
      msgs += { error(msg, u)
              | expType != typeOf(lhs, tenv, useDef) || expType != typeOf(rhs, tenv, useDef) 
              || typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)
              };
    }
    case sub(lhs,rhs,src = loc u): {
      msgs += { error(msg, u)
              | expType != typeOf(lhs, tenv, useDef) || expType != typeOf(rhs, tenv, useDef) 
              || typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)
              };
    }
    case lt(lhs,rhs,src = loc u): {
      msgs += { error(msg, u)
              | expType != typeOf(lhs, tenv, useDef) || expType != typeOf(rhs, tenv, useDef) 
              || typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)
              };
    }
    case leq(lhs,rhs,src = loc u): {
      msgs += { error(msg, u)
              | expType != typeOf(lhs, tenv, useDef) || expType != typeOf(rhs, tenv, useDef) 
              || typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)
              };
    }
    case gt(lhs,rhs,src = loc u): {
      msgs += { error(msg, u)
              | expType != typeOf(lhs, tenv, useDef) || expType != typeOf(rhs, tenv, useDef) 
              || typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)
              };
    }
    case geq(lhs,rhs,src = loc u): {
      msgs += { error(msg, u)
              | expType != typeOf(lhs, tenv, useDef) || expType != typeOf(rhs, tenv, useDef) 
              || typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)
              };
    }
    case eq(lhs,rhs,src = loc u): {
      msgs += { error(msg, u)
              | expType != typeOf(lhs, tenv, useDef) || expType != typeOf(rhs, tenv, useDef) 
              || typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)
              };
    }
    case neq(lhs,rhs,src = loc u): {
      msgs += { error(msg, u)
              | expType != typeOf(lhs, tenv, useDef) || expType != typeOf(rhs, tenv, useDef) 
              || typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)
              };
    }
    case and(lhs,rhs,src = loc u): {
      msgs += { error(msg, u)
              | expType != typeOf(lhs, tenv, useDef) || expType != typeOf(rhs, tenv, useDef) 
              || typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)
              };
    }
    case or(lhs,rhs,src = loc u): {
      msgs += { error(msg, u)
              | expType != typeOf(lhs, tenv, useDef) || expType != typeOf(rhs, tenv, useDef) 
              || typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef)
              };
    }
  }
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(AId id, src = loc u):  
      if (<u, loc d> <- useDef, <d, "<id.name>", _, Type t> <- tenv) {
        return t;
      }
    case const(AConst val):
      return toType(val);
    case brack(AExpr exp):
      return typeOf(exp, tenv, useDef);
    case not(_):
      return tbool();
    case mul(_, _):
      return tint();
    case div(_, _):
      return tint();
    case add(_, _):
      return tint();
    case sub(_, _):
      return tint();
    case lt(_, _):
      return tbool();
    case leq(_, _):
      return tbool();
    case gt(_, _):
      return tbool();
    case geq(_, _):
      return tbool();
    case eq(_, _):
      return tbool();
    case neq(_, _):
      return tbool();
    case and(_, _):
      return tbool();
    case or(_, _):
      return tbool();
  }
  return tunknown(); 
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(str x, src = loc u), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

