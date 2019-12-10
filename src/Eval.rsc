module Eval

import AST;
import Resolve;

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.


// Semantic domain for expressions (values)
data Value
	= vint(int n)
	| vbool(bool b)
	| vstr(str s)
	;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input
	= input(str question, Value \value);
	
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
	return (name : defaultValue(t) | /question(_, id(name), t, _) := f);
}

Value defaultValue(AType t) {
	switch (t) {
		case integer():
			return vint(0);
		case boolean():
			return vbool(false);
		case string():
			return vstr("");
	}
}


// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
	return solve (venv) {
		venv = evalOnce(f, inp, venv);
	}
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
	return (); 
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
	// evaluate conditions for branching,
	// evaluate inp and computed questions to return updated VEnv
	venv[input.question] = input.\value;
	return (n : (e == empty() ? venv[n] : eval(e, venv)) | n <- venv, question(_,_,_,e) := q); 
}

Value eval(AExpr e, VEnv venv) {
	switch (e) {
		case ref(AId x): return venv[x.name];
		case const(AConst x): return eval(x);
		case brack(AExpr x): return eval(x, venv);
		case not(AExpr x): return vbool(!(eval(x, venv).b));
		case mul(AExpr l, AExpr r): return vint(eval(l, venv).b * eval(r, venv).b);
		case div(AExpr l, AExpr r): return vint(eval(l, venv).b / eval(r, venv).b);
		case add(AExpr l, AExpr r): return vint(eval(l, venv).b + eval(r, venv).b);
		case sub(AExpr l, AExpr r): return vint(eval(l, venv).b - eval(r, venv).b);
		case lt(AExpr l, AExpr r): return vbool(eval(l, venv).b < eval(r, venv).b);
		case leq(AExpr l, AExpr r): return vbool(eval(l, venv).b <= eval(r, venv).b);
		case gt(AExpr l, AExpr r): return vbool(eval(l, venv).b > eval(r, venv).b);
		case geq(AExpr l, AExpr r): return vbool(eval(l, venv).b >= eval(r, venv).b);
		case eq(AExpr l, AExpr r): return vbool(eval(l, venv).b == eval(r, venv).b);
		case neq(AExpr l, AExpr r): return vbool(eval(l, venv).b != eval(r, venv).b);
		case and(AExpr l, AExpr r): return vbool(eval(l, venv).b && eval(r, venv).b);
		case or(AExpr l, AExpr r): return vbool(eval(l, venv).b || eval(r, venv).b);
		default: throw "Unsupported expression <e>";
	}
}

Value eval(AConst c) {
	switch (c) {
		case integer(x): return vint(x);
		case string(x): return vstr(x);
		case boolean(x): return vbool(x);
	}
}