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
    case "question"(label,x,declType): 
        return question("<label>", id("<x>", src=x@\loc), "<declType>", src=q@\loc);
    case "computed"(label,x,declType,exp): 
        return computed("<label>", id("<x>", src=x@\loc), "<declType>", cst2ast(exp), src=q@\loc);
    case "block"(questions): 
        return block([cst2ast(q) | q <- questions], src=q@\loc);
    case "ifthen"(guard,ifqs): 
        return ifthen(cst2ast(guard), [cst2ast(iq) | iq <- ifqs], src=q@\loc);
    case "ifthenelse"(guard,ifqs,elseqs): 
        return ifthenelse(cst2ast(guard), [cst2ast(iq) | iq <- ifqs], [cst2ast(eq) | eq <- elseqs], src=q@\loc);
    default: throw "Unhandled question <q>";
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref("<x>", src=x@\loc);
    case (Expr)`<Type t>`: return var(cst2ast(t), src=t@\loc);
    case (Expr)`(<Expr exp>)`: return cst2ast(exp); 
    case "not"(exp): return not(cst2ast(exp), src=e@\loc);

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
  switch(t) {
    case "integer"(iVal): return nat(toInt("<iVal>"), src=iVal@\loc);
    case "string"(sVal): return string("<sVal>", src=sVal@\loc);
    case "boolean"(bVal): return boolean(fromString("<bVal>"), src=bVal@\loc);
  }
}
