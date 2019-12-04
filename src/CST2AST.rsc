module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(start[Form] sf) {
  Form f = sf.top; // remove layout before and after form
  return form("<f.id>", [cst2ast(q) | q <- f.qs], src=f@\loc); 
}

AQuestion cst2ast(Question q) {
  switch(q) {
    case "question"(label,x,tp): 
        return question("<label>", id("<x>", src=x@\loc), cst2ast(tp));
    case "computed"(label,x,tp,exp): 
        return computed("<label>", id("<x>", src=x@\loc), cst2ast(tp), cst2ast(exp));
    case "block"(questions): 
        return block([cst2ast(q) | q <- questions]);
    case "ifthen"(guard,ifqs): 
        return ifthen(cst2ast(guard), [cst2ast(iq) | iq <- ifqs]);
    case "ifthenelse"(guard,ifqs,elseqs): 
        return ifthenelse(cst2ast(guard), [cst2ast(iq) | iq <- ifqs], [cst2ast(eq) | eq <- elseqs]);
    default: throw "Unhandled question <q>";
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case "iden"(x): return ref(id("<x>", src=x@\loc), src=x@\loc);
    case "constant"(val): return const(cst2ast(val), src=val@\loc);
    case "brack"(exp): return cst2ast(exp); 
    case "not"(exp): return not(cst2ast(exp));

    case "mul"(lhs,rhs): return mul(cst2ast(lhs), cst2ast(rhs));
    case "div"(lhs,rhs): return div(cst2ast(lhs), cst2ast(rhs));
    case "add"(lhs,rhs): return add(cst2ast(lhs), cst2ast(rhs));
    case "sub"(lhs,rhs): return sub(cst2ast(lhs), cst2ast(rhs));

    case "lt"(lhs,rhs): return lt(cst2ast(lhs), cst2ast(rhs));
    case "leq"(lhs,rhs): return leq(cst2ast(lhs), cst2ast(rhs));
    case "gt"(lhs,rhs): return gt(cst2ast(lhs), cst2ast(rhs));
    case "geq"(lhs,rhs): return geq(cst2ast(lhs), cst2ast(rhs));

    case "eq"(lhs,rhs): return eq(cst2ast(lhs), cst2ast(rhs));
    case "neq"(lhs,rhs): return neq(cst2ast(lhs), cst2ast(rhs));
    
    case "and"(lhs,rhs): return and(cst2ast(lhs), cst2ast(rhs));
    case "or"(lhs,rhs): return or(cst2ast(lhs), cst2ast(rhs));

    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
  switch("<t>") {
    case "integer": return integer();
    case "string": return string();
    case "boolean": return boolean();
  }
}

AConst cst2ast(Const c) {
    switch(c)  {
        case "integer"(iVal): return integer(toInt("<iVal>"), src=iVal@\loc);
        case "string"(sVal): return string("<sVal>", src=sVal@\loc);
        case "boolean"(bVal): return boolean(fromString("<bVal>"), src=bVal@\loc);
    }
}
