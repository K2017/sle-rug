module Transform

import Syntax;
import Resolve;
import AST;

import List;
import Relation;
import IO;
import ParseTree;

import lang::std::Id;

/* 
 * Transforming QL forms
 */
 
 
/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */
 
AForm flatten(AForm f) {
  return form(f.name, concat([flatten(q, const(boolean(true))) | q <- f.questions]), src = f.src); 
}

list[AQuestion] flatten(ifthen(AExpr guard, AQuestion ifq), AExpr exp) {
  return flatten(ifq, and(guard, exp));
}

list[AQuestion] flatten(ifthenelse(AExpr guard, AQuestion ifq, AQuestion elseq), AExpr exp) {
  return flatten(ifq, and(guard, exp)) + flatten(elseq, and(not(guard), exp));
}

list[AQuestion] flatten(block(list[AQuestion] qs), AExpr exp) {
  return concat([flatten(q, exp) | q <- qs]);
}

list[AQuestion] flatten(q:question(_,_,_), AExpr exp) {
  return [ifthen(exp, q)];
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
 start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
 	set[loc] uses = useDef[useOrDef];
 	set[loc] defs = ({} | it + invert(useDef)[l] | loc l <- uses + {useOrDef});
 	set[loc] locs = uses + defs + {useOrDef};
 	println(locs);

 	f = visit (f) {
 		case /"question"(label,x,tp) => x@\loc in locs ? parse(#Question, "<label> <newName> : <tp>") : parse(#Question, "<label> <x> : <tp>")
 		case /"iden"(x) => x@\loc in locs ? parse(#Id, newName) : x
 	}
   	return f; 
 } 
 
 
 

