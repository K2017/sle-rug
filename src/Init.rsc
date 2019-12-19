module Init

import ParseTree;
import IO;

import Syntax;
import AST;
import CST2AST;
import Resolve;
import Check;
import Eval;
import Compile;
import Transform;

value initql(loc file) {
  pt = parse(#start[Form], file);

  ast = cst2ast(pt);

  res = resolve(ast);

  env = collect(ast);

  msgs = check(ast, env, res[2]);

  if ({m | m:error(_,_) <- msgs} == {}) {
    ast = flatten(ast);
  	VEnv venv = initialEnv(ast);

  	Input inp1 = input("sellingPrice", vint(5));
  	Input inp2 = input("privateDebt", vint(2));
  	venv = eval(ast, inp1, venv);
  	venv = eval(ast, inp2, venv);
    compile(ast);
  	return venv;
  } else {
  	return msgs;
  }
}
