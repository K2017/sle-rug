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

/* Normal and Computed questions are disambiguated through the use of an 
 * optional expression parameter that can be matched against
 */
data AQuestion(loc src = |tmp:///|)
  = question(str label, AId id, AType tp, AExpr ex = empty())
  | block(list[AQuestion] bquestions)
  | ifthen(AExpr guard, AQuestion ifq)
  | ifthenelse(AExpr guard, AQuestion ifq, AQuestion elseq)
  ; 

data AExpr(loc src = |tmp:///|)
  = empty()
  | ref(AId id)
  | const(AConst val)

  | brack(AExpr exp)

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
  = integer()
  | string()
  | boolean()
  | unknown()
  ;

data AConst(loc src = |tmp:///|)
  = integer(int iVal) 
  | string(str sVal)
  | boolean(bool bVal)
  | unknown()
  ; 
