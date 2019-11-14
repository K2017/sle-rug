module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id id "{" Question* questions "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question
  = question: Str label Id id":" Type tp
  | computed: Str label Id id":" Type tp "=" Expr exp
  | block: "{" Question* "}" block
  | ifthen: "if" "(" Expr exp ")" guard "{" Question* "}" thenPart
  | ifthenelse: "if" "(" Expr exp ")" guard "{" Question* "}" thenPart "else" "{" Question* "}" elsePart
  ; 

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  | Str
  | Int
  | Bool
  | bracket "(" Expr e ")"
  > right not: "!" Expr e 
  > left (mult: Expr l "*" Expr r
         | div: Expr l "/" Expr r
         )
  > left ( add: Expr l "+" Expr r
         | sub: Expr l "-" Expr r
         )
  > left ( lt: Expr l "\<" Expr r
         | lte: Expr l "\<=" Expr r
         | gt: Expr l "\>" Expr r
         | gte: Expr l "\>=" Expr r
         )
  > left ( equ: Expr l "==" Expr r
         | nequ: Expr l "!=" Expr r
         )
  > left and: Expr l "&&" Expr r
  > left or: Expr l "||" Expr r
  ;
  
syntax Type 
  = integer: "integer"
  | string: "string"
  | boolean: "boolean"
  ;  
  
lexical Str = "\"" ![\"]* "\"";

lexical Int = [0-9]+ ;

lexical Bool = "true" | "false";



