module Init

import ParseTree;
import IO;

import Syntax;
import AST;
import CST2AST;
import Resolve;
import Check;

set[Message] initql(loc file) {
  pt = parse(#start[Form], file);

  ast = cst2ast(pt);

  res = resolve(ast);

  env = collect(ast);

  msgs = check(ast, env, res[2]);
  return msgs;
}
