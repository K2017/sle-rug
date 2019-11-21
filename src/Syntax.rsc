module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id id "{" Question* qs "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question
  = question: Str Id ":" TypeDecl 
  | computed: Str Id ":" TypeDecl "=" Expr
  | block: "{" Question* "}" 
  | ifthen: "if" "(" Expr ")" "{" Question* "}" 
  | ifthenelse: "if" "(" Expr ")" "{" Question* "}" "else" "{" Question* "}" 
  ; 

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  | Type
  | bracket "(" Expr e ")"
  > right not: "!" Expr e 
  > left ( mul: Expr l "*" Expr r
         | div: Expr l "/" Expr r
         )
  > left ( add: Expr l "+" Expr r
         | sub: Expr l "-" Expr r
         )
  > left ( lt: Expr l "\<" Expr r
         | leq: Expr l "\<=" Expr r
         | gt: Expr l "\>" Expr r
         | geq: Expr l "\>=" Expr r
         )
  > left ( eq: Expr l "==" Expr r
         | neq: Expr l "!=" Expr r
         )
  > left and: Expr l "&&" Expr r
  > left or: Expr l "||" Expr r
  ;
  
syntax Type 
  = integer: Int
  | string: Str
  | boolean: Bool
  ;  

syntax TypeDecl
  = integer: "integer"
  | string: "string"
  | boolean: "boolean"
  ;
  
lexical Str = "\"" ![\"]* "\"";

lexical Int = [0-9]+ ;

lexical Bool = "true" | "false";



