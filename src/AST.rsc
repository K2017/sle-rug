module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(str name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|)
  = question(str label, AId id, str declType)
  | computed(str label, AId id, str declType, AExpr expr)
  | block(list[AQuestion] questions)
  | ifthen(AExpr guard, list[AQuestion] questions)
  | ifthenelse(AExpr guard, list[AQuestion] ifqs, list[AQuestion] elseqs)
  ; 

data AExpr(loc src = |tmp:///|)
  = ref(str x)
  | var(AType val)

  | not(AExpr exp)
  | mul(AExpr lhs, AExpr rhs)
  | div(AExpr lhs, AExpr rhs)
  | add(AExpr lhs, AExpr rhs)
  | sub(AExpr lhs, AExpr rhs)

  | lt(AExpr lhs, AExpr rhs)
  | leq(AExpr lhs, AExpr rhs)
  | gt(AExpr lhs, AExpr rhs)
  | geq(AExpr lhs, AExpr rhs)

  | eq(AExpr lhs, AExpr rhs)
  | neq(AExpr lhs, AExpr rhs)

  | and(AExpr lhs, AExpr rhs)
  | or(AExpr lhs, AExpr rhs)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = nat(int iVal) 
  | string(str sVal)
  | boolean(bool bVal)
  ;
